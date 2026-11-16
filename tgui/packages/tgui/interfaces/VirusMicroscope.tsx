import { Button, Slider } from 'tgui-core/components';
import { useBackend } from '../backend';
import { useEffect, useRef, useState } from 'react';
import { Window } from '../layouts';

type MicroscopeReagent = {
  id: string;
  name: string;
  volume: number;
  color: string;
  is_vaccine: boolean;
};

type MicroscopeAddedReagent = {
  id: string;
  name: string;
  amount: number;
  color: string;
  is_vaccine: boolean;
};

type MicroscopeVirusSeed = {
  name: string;
  cure_reagents: string[];
};

type VirusMicroscopeData = {
  microscope_available_reagents: MicroscopeReagent[];
  microscope_added_reagents: MicroscopeAddedReagent[];
  microscope_food_amount: number;
  microscope_food_capacity: number;
  microscope_reagent_storage_amount: number;
  microscope_reagent_storage_capacity: number;
  microscope_reagent_storage_types: number;
  microscope_reagent_type_limit: number;
  microscope_virus_seeds: MicroscopeVirusSeed[];
  microscope_culture_generation: number;
};

type ReagentParticle = {
  id: number;
  reagentId: string;
  isVaccine: boolean;
  foodValue: number;
  color: string;
  x: number;
  y: number;
  vx: number;
  vy: number;
  radius: number;
};

type MicroscopeSimulation = {
  cells: VirusCell[];
  particles: ReagentParticle[];
};

type CellStage = 'normal' | 'growing' | 'stretching' | 'splitting' | 'dying';

type VirusCellData = {
  id: number;
  name: string;
  x: number;
  y: number;
  vx: number;
  vy: number;
  age: number;
  size: number;
  food: number;
  outerReagentId: string | null;
  innerReagentId: string | null;
  outerStrength: number;
  innerStrength: number;
  nucleusStrength: number;
  stage: CellStage;
  stageTicks: number;
};

class VirusCell {
  id: number;
  name: string;
  x: number;
  y: number;
  vx: number;
  vy: number;
  age: number;
  size: number;
  food: number;
  outerReagentId: string | null;
  innerReagentId: string | null;
  outerStrength: number;
  innerStrength: number;
  nucleusStrength: number;
  stage: CellStage;
  stageTicks: number;

  constructor(properties: VirusCellData) {
    this.id = properties.id;
    this.name = properties.name;
    this.x = properties.x;
    this.y = properties.y;
    this.vx = properties.vx;
    this.vy = properties.vy;
    this.age = properties.age;
    this.size = properties.size;
    this.food = properties.food;
    this.outerReagentId = properties.outerReagentId;
    this.innerReagentId = properties.innerReagentId;
    this.outerStrength = properties.outerStrength;
    this.innerStrength = properties.innerStrength;
    this.nucleusStrength = properties.nucleusStrength;
    this.stage = properties.stage;
    this.stageTicks = properties.stageTicks;
  }

  with(changes: Partial<VirusCellData>): VirusCell {
    return new VirusCell({ ...this, ...changes });
  }
}

const AREA_WIDTH = 800;
const AREA_HEIGHT = 460;

const MAX_CELLS = 10;
const START_CELLS = 6;

const TICK_INTERVAL = 80;
const INNER_STRENGTH_DECAY_INTERVAL = 18;
const UNCOMFORTABLE_INNER_DECAY_INTERVAL = 5;
const INNER_REPAIR_INTERVAL = 20;
const FOOD_PER_INNER_REPAIR = 0.1;
const NUCLEUS_STRENGTH_DECAY_INTERVAL = 54;
const UNCOMFORTABLE_NUCLEUS_DECAY_INTERVAL = 15;
const COMFORTABLE_TEMP_MIN = 10;
const COMFORTABLE_TEMP_MAX = 20;
const MIN_TEMPERATURE = 0;
const MAX_TEMPERATURE = 30;
const VIRUS_FOOD_REAGENT_ID = 'virusfood';
const VACCINE_NUCLEUS_DAMAGE = 35;
const LAYER_DAMAGE_PER_PARTICLE = 8;
const FOOD_FOR_DIVISION = 5;
const MAX_CELL_FOOD = 5;
const PARTICLES_PER_UNIT = 1;
const MAX_REAGENT_PARTICLES = 80;
const PARTICLE_RADIUS = 1;

const GROWTH_TICKS = 28;
const STRETCH_TICKS = 24;
const SPLIT_TICKS = 18;
const DYING_TICKS = 60;

const clamp = (value: number, min: number, max: number) =>
  Math.max(min, Math.min(max, value));

const randomStrength = () => 88 + Math.round(Math.random() * 12);

const createInitialCells = (
  virusSeeds: MicroscopeVirusSeed[],
): VirusCell[] => {
  if (!virusSeeds.length) {
    return [];
  }

  const positions = [
    [110, 90],
    [285, 185],
    [480, 95],
    [680, 160],
    [185, 355],
    [535, 345],
    [370, 80],
    [640, 350],
    [80, 245],
    [400, 380],
  ];

  const initialCellCount = Math.min(
    MAX_CELLS,
    Math.max(START_CELLS, virusSeeds.length),
  );

  return positions.slice(0, initialCellCount).map(([x, y], index) => {
    const seed = virusSeeds[index % virusSeeds.length];
    const cures = seed.cure_reagents || [];
    const id = index + 1;
    return new VirusCell({
      id,
      name: seed.name,
      x,
      y,
      vx: (Math.random() - 0.5) * 2.2,
      vy: (Math.random() - 0.5) * 2.2,
      age: 0,
      size: 17 + Math.round(Math.random() * 3),
      food: 0,
      outerReagentId: cures[0] || null,
      innerReagentId: cures[1] || null,
      outerStrength: randomStrength(),
      innerStrength: randomStrength(),
      nucleusStrength: randomStrength(),
      stage: 'normal',
      stageTicks: 0,
    });
  });
};

const createReagentParticles = (
  reagents: MicroscopeAddedReagent[],
  existingParticles: ReagentParticle[] = [],
): ReagentParticle[] => {
  const particles: ReagentParticle[] = [];
  let nextId =
    existingParticles.reduce(
      (highest, particle) => Math.max(highest, particle.id),
      0,
    ) + 1;

  for (const reagent of reagents) {
    const count = Math.min(
      MAX_REAGENT_PARTICLES - existingParticles.length - particles.length,
      Math.ceil(reagent.amount * PARTICLES_PER_UNIT),
    );
    // Each food particle carries one full unit of nutrition.
    const foodValue = reagent.id === VIRUS_FOOD_REAGENT_ID ? 1 : 0;

    for (let index = 0; index < count; index++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 4.5 + Math.random() * 4;
      particles.push({
        id: nextId++,
        reagentId: reagent.id,
        isVaccine: reagent.is_vaccine,
        foodValue,
        color: reagent.is_vaccine ? '#4b9cff' : reagent.color || '#42e58d',
        x: 12 + Math.random() * (AREA_WIDTH - 24),
        y: 12 + Math.random() * (AREA_HEIGHT - 24),
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        radius: PARTICLE_RADIUS,
      });
    }

    if (particles.length >= MAX_REAGENT_PARTICLES) {
      break;
    }
  }

  return particles;
};

const moveCell = (cell: VirusCell): VirusCell => {
  let x = cell.x + cell.vx;
  let y = cell.y + cell.vy;
  let vx = cell.vx;
  let vy = cell.vy;

  if (x < cell.size + 4 || x > AREA_WIDTH - cell.size - 4) {
    vx *= -1;
    x = clamp(x, cell.size + 4, AREA_WIDTH - cell.size - 4);
  }
  if (y < cell.size + 4 || y > AREA_HEIGHT - cell.size - 4) {
    vy *= -1;
    y = clamp(y, cell.size + 4, AREA_HEIGHT - cell.size - 4);
  }

  return cell.with({ x, y, vx, vy });
};

const getSplitOffset = (cell: VirusCell, progress: number) => {
  const speed = Math.hypot(cell.vx, cell.vy) || 1;
  const distance = cell.size * 1.05 * progress;
  return {
    x: (-cell.vy / speed) * distance,
    y: (cell.vx / speed) * distance,
  };
};

const advanceCells = (
  cells: VirusCell[],
  temperature: number,
  foodAvailable: boolean,
): VirusCell[] => {
  const next: VirusCell[] = [];
  const offspring: VirusCell[] = [];
  let nextId = cells.reduce((highest, cell) => Math.max(highest, cell.id), 0) + 1;
  const comfortable =
    temperature >= COMFORTABLE_TEMP_MIN &&
    temperature <= COMFORTABLE_TEMP_MAX;
  for (const cell of cells) {
    const moved = cell.stage === 'dying' ? cell : moveCell(cell);
    let updated = moved.with({ age: cell.age + 1 });

    if (updated.stage !== 'dying' && updated.age > 0) {
      let innerStrength = updated.innerStrength;
      let nucleusStrength = updated.nucleusStrength;

      const innerDecayInterval = comfortable
        ? INNER_STRENGTH_DECAY_INTERVAL
        : UNCOMFORTABLE_INNER_DECAY_INTERVAL;
      const nucleusDecayInterval = comfortable
        ? NUCLEUS_STRENGTH_DECAY_INTERVAL
        : UNCOMFORTABLE_NUCLEUS_DECAY_INTERVAL;
      let cellFood = updated.food;

      // Nutrients protect the inner layer from age damage and slowly repair it.
      // One repair point costs 0.1 food and is applied every 1.6 seconds.
      if (cellFood > 0) {
        if (
          innerStrength < 100 &&
          updated.age % INNER_REPAIR_INTERVAL === 0
        ) {
          innerStrength = Math.min(100, innerStrength + 1);
          cellFood = Math.max(0, cellFood - FOOD_PER_INNER_REPAIR);
        }
      } else if (
        innerStrength > 0 &&
        updated.age % innerDecayInterval === 0
      ) {
        innerStrength = Math.max(0, innerStrength - 1);
      }

      // The nucleus only starts aging after the inner layer is gone and the
      // cell has no nutrients left to recover it.
      if (
        innerStrength === 0 &&
        cellFood <= 0 &&
        nucleusStrength > 0 &&
        updated.age % nucleusDecayInterval === 0
      ) {
        nucleusStrength = Math.max(0, nucleusStrength - 1);
      }

      updated = updated.with({ innerStrength, nucleusStrength, food: cellFood });
    }

    if (
      updated.stage !== 'dying' &&
      updated.innerStrength === 0 &&
      updated.nucleusStrength === 0
    ) {
      updated = updated.with({ stage: 'dying', stageTicks: 0 });
    }

    if (updated.stage === 'dying') {
      const stageTicks = updated.stageTicks + 1;
      if (stageTicks < DYING_TICKS) {
        next.push(updated.with({ stageTicks }));
      }
      continue;
    }

    if (updated.stage === 'growing') {
      const stageTicks = updated.stageTicks + 1;
      next.push(
        stageTicks >= GROWTH_TICKS
          ? updated.with({ stage: 'stretching', stageTicks: 0 })
          : updated.with({ stageTicks }),
      );
      continue;
    }

    if (updated.stage === 'stretching') {
      const stageTicks = updated.stageTicks + 1;
      next.push(
        stageTicks >= STRETCH_TICKS
          ? updated.with({ stage: 'splitting', stageTicks: 0 })
          : updated.with({ stageTicks }),
      );
      continue;
    }

    if (updated.stage === 'splitting') {
      const stageTicks = updated.stageTicks + 1;
      if (stageTicks >= SPLIT_TICKS) {
        const offset = getSplitOffset(updated, 1);
        const directionX = offset.x / (updated.size * 1.05);
        const directionY = offset.y / (updated.size * 1.05);
        const parentX = clamp(
          updated.x - offset.x,
          updated.size + 4,
          AREA_WIDTH - updated.size - 4,
        );
        const parentY = clamp(
          updated.y - offset.y,
          updated.size + 4,
          AREA_HEIGHT - updated.size - 4,
        );

        next.push(
          updated.with({
            x: parentX,
            y: parentY,
            vx: updated.vx - directionX * 0.35,
            vy: updated.vy - directionY * 0.35,
            age: 0,
            food: 0,
            outerStrength: 100,
            innerStrength: 100,
            nucleusStrength: 100,
            stage: 'normal',
            stageTicks: 0,
          }),
        );

        if (next.length + offspring.length < MAX_CELLS) {
          offspring.push(
            new VirusCell({
              ...updated,
              id: nextId++,
              x: clamp(
                updated.x + offset.x,
                updated.size + 4,
                AREA_WIDTH - updated.size - 4,
              ),
              y: clamp(
                updated.y + offset.y,
                updated.size + 4,
                AREA_HEIGHT - updated.size - 4,
              ),
              vx: updated.vx + directionX * 0.35,
              vy: updated.vy + directionY * 0.35,
              age: 0,
              food: 0,
              outerStrength: 100,
              innerStrength: 100,
              nucleusStrength: 100,
              stage: 'normal',
              stageTicks: 0,
            }),
          );
        }
      } else {
        next.push(updated.with({ stageTicks }));
      }
      continue;
    }

    next.push(updated);
  }

  next.push(...offspring);

  const hasDyingCell = next.some((cell) => cell.stage === 'dying');
  const divisionInProgress = next.some(
    (cell) =>
      cell.stage === 'growing' ||
      cell.stage === 'stretching' ||
      cell.stage === 'splitting',
  );

  if (
    comfortable &&
    foodAvailable &&
    !hasDyingCell &&
    !divisionInProgress &&
    next.length < MAX_CELLS
  ) {
    const readyCell = next
      .map((cell, index) => ({ cell, index }))
      .filter(
        ({ cell }) =>
          cell.stage === 'normal' && cell.food >= FOOD_FOR_DIVISION,
      )
      .sort((a, b) => b.cell.food - a.cell.food)[0];

    if (readyCell) {
      next[readyCell.index] = readyCell.cell.with({
        food: Math.max(0, readyCell.cell.food - FOOD_FOR_DIVISION),
        stage: 'growing',
        stageTicks: 0,
      });
    }
  }

  return next;
};

const distanceToSegment = (
  pointX: number,
  pointY: number,
  startX: number,
  startY: number,
  endX: number,
  endY: number,
): number => {
  const dx = endX - startX;
  const dy = endY - startY;
  const lengthSquared = dx * dx + dy * dy;
  if (lengthSquared === 0) {
    return Math.hypot(pointX - startX, pointY - startY);
  }

  const projection = clamp(
    ((pointX - startX) * dx + (pointY - startY) * dy) / lengthSquared,
    0,
    1,
  );
  const closestX = startX + projection * dx;
  const closestY = startY + projection * dy;
  return Math.hypot(pointX - closestX, pointY - closestY);
};

const advanceReagentParticles = (
  particles: ReagentParticle[],
  cells: VirusCell[],
  deltaScale: number,
): MicroscopeSimulation => {
  const nextParticles: ReagentParticle[] = [];
  const nextCells = cells.slice();

  for (const particle of particles) {
    let vx = particle.vx;
    let vy = particle.vy;

    const nearestCell = nextCells
      .filter((cell) => cell.stage !== 'dying')
      .reduce<{ cell: VirusCell | null; distance: number }>(
        (nearest, cell) => {
          const distance = Math.hypot(
            cell.x - particle.x,
            cell.y - particle.y,
          );
          return distance < nearest.distance
            ? { cell, distance }
            : nearest;
        },
        { cell: null, distance: Number.POSITIVE_INFINITY },
      ).cell;

    if (nearestCell) {
      const targetX = nearestCell.x - particle.x;
      const targetY = nearestCell.y - particle.y;
      const targetDistance = Math.hypot(targetX, targetY) || 1;
      const currentSpeed = Math.max(Math.hypot(vx, vy), 4.5);
      const desiredVx = (targetX / targetDistance) * currentSpeed;
      const desiredVy = (targetY / targetDistance) * currentSpeed;
      const attraction = clamp(0.18 * deltaScale, 0, 0.25);

      // Smooth steering keeps particles moving naturally while biasing them
      // toward the closest cell instead of letting them drift indefinitely.
      vx += (desiredVx - vx) * attraction;
      vy += (desiredVy - vy) * attraction;
    }

    let x = particle.x + vx * deltaScale;
    let y = particle.y + vy * deltaScale;

    if (x < particle.radius || x > AREA_WIDTH - particle.radius) {
      vx *= -1;
      x = clamp(x, particle.radius, AREA_WIDTH - particle.radius);
    }
    if (y < particle.radius || y > AREA_HEIGHT - particle.radius) {
      vy *= -1;
      y = clamp(y, particle.radius, AREA_HEIGHT - particle.radius);
    }

    // Check the whole movement segment, not only the final position, so fast
    // particles cannot skip over a cell between simulation frames.
    const touchedCellIndex = nextCells.findIndex(
      (cell) =>
        cell.stage !== 'dying' &&
        distanceToSegment(
          cell.x,
          cell.y,
          particle.x,
          particle.y,
          x,
          y,
        ) <=
          cell.size + particle.radius,
    );

    let particleConsumed = false;
    if (touchedCellIndex !== -1) {
      const touchedCell = nextCells[touchedCellIndex];

      if (particle.reagentId === VIRUS_FOOD_REAGENT_ID) {
        nextCells[touchedCellIndex] = touchedCell.with({
          food: clamp(
            touchedCell.food + particle.foodValue,
            0,
            MAX_CELL_FOOD,
          ),
        });
      } else if (particle.isVaccine && touchedCell.nucleusStrength > 0) {
        const nucleusStrength = Math.max(
          0,
          touchedCell.nucleusStrength - VACCINE_NUCLEUS_DAMAGE,
        );
        nextCells[touchedCellIndex] = touchedCell.with({
          nucleusStrength,
          ...(nucleusStrength === 0
            ? { stage: 'dying' as const, stageTicks: 0 }
            : {}),
        });
      } else if (
        touchedCell.outerReagentId !== null &&
        particle.reagentId === touchedCell.outerReagentId &&
        touchedCell.outerStrength > 0
      ) {
        nextCells[touchedCellIndex] = touchedCell.with({
          outerStrength: Math.max(
            0,
            touchedCell.outerStrength - LAYER_DAMAGE_PER_PARTICLE,
          ),
        });
      } else if (
        touchedCell.innerReagentId !== null &&
        particle.reagentId === touchedCell.innerReagentId &&
        touchedCell.outerStrength <= 0 &&
        touchedCell.innerStrength > 0
      ) {
        nextCells[touchedCellIndex] = touchedCell.with({
          innerStrength: Math.max(
            0,
            touchedCell.innerStrength - LAYER_DAMAGE_PER_PARTICLE,
          ),
        });
      }

      // Every reagent is absorbed on contact, even when it has no special
      // effect on this virus.
      particleConsumed = true;
    }

    if (!particleConsumed) {
      nextParticles.push({ ...particle, x, y, vx, vy });
    }
  }

  return { cells: nextCells, particles: nextParticles };
};

const renderCellSprite = (
  cell: VirusCell,
  x: number,
  y: number,
  scaleX: number,
  scaleY: number,
  opacity: number,
  selected: boolean,
  onSelect: (id: number) => void,
  part: string,
) => (
  <g
    key={cell.id + '-' + part}
    transform={
      'translate(' +
      x +
      ' ' +
      y +
      ') scale(' +
      (cell.size / 20) * scaleX +
      ' ' +
      (cell.size / 20) * scaleY +
      ')'
    }
    style={{ cursor: 'pointer', opacity }}
    role="button"
    aria-label={'Выбрать ' + cell.name + ' №' + cell.id}
    onClick={() => onSelect(cell.id)}
  >
    {selected && (
      <circle
        r="24"
        fill="none"
        stroke="#ffd27a"
        strokeWidth="1.5"
        strokeDasharray="3 3"
      />
    )}
    <path
      d="M -8 -20 H 8 V -16 H 16 V -8 H 20 V 8 H 16 V 16 H 8 V 20 H -8 V 16 H -16 V 8 H -20 V -8 H -16 V -16 H -8 Z"
      fill={
        cell.outerStrength > 65
          ? '#741b2c'
          : cell.outerStrength > 30
            ? '#a34c35'
            : '#626b7a'
      }
      opacity={0.35 + cell.outerStrength / 150}
    />
    <path
      d="M -8 -16 H 8 V -12 H 12 V -8 H 16 V 8 H 12 V 12 H 8 V 16 H -8 V 12 H -12 V 8 H -16 V -8 H -12 V -12 H -8 Z"
      fill="#df4b5b"
    />
    <path
      d="M -4 -8 H 4 V -4 H 8 V 4 H 4 V 8 H -4 V 4 H -8 V -4 H -4 Z"
      fill="#641629"
    />
    <rect x="-4" y="-4" width="4" height="4" fill="#a92e43" />
  </g>
);

const StrengthMeter = ({
  label,
  value,
}: {
  label: string;
  value: number;
}) => {
  const safeValue = clamp(value, 0, 100);
  const barColor =
    safeValue > 65 ? '#df4b5b' : safeValue > 35 ? '#d58a43' : '#9b4650';

  return (
    <div style={{ marginTop: '8px' }}>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          gap: '8px',
          fontSize: '11px',
          color: '#e5eaf2',
        }}
      >
        <span>{label}</span>
        <b>{safeValue}%</b>
      </div>
      <div
        style={{
          height: '5px',
          marginTop: '3px',
          backgroundColor: '#263449',
          borderRadius: '3px',
          overflow: 'hidden',
        }}
      >
        <div
          style={{
            width: safeValue + '%',
            height: '100%',
            backgroundColor: barColor,
          }}
        />
      </div>
    </div>
  );
};

export const VirusMicroscope = (_props: unknown) => {
  const { act, data } = useBackend<VirusMicroscopeData>();
  const availableReagents = data.microscope_available_reagents || [];
  const addedReagents = data.microscope_added_reagents || [];
  const virusSeeds = data.microscope_virus_seeds || [];
  const cultureGeneration = data.microscope_culture_generation || 0;
  const foodReceiverAmount = data.microscope_food_amount || 0;
  const foodReceiverCapacity = data.microscope_food_capacity || 100;
  const reagentStorageAmount = data.microscope_reagent_storage_amount || 0;
  const reagentStorageCapacity =
    data.microscope_reagent_storage_capacity || 100;
  const reagentStorageTypes = data.microscope_reagent_storage_types || 0;
  const reagentTypeLimit = data.microscope_reagent_type_limit || 3;
  const [simulation, setSimulation] = useState<MicroscopeSimulation>(() => ({
    cells: createInitialCells(virusSeeds),
    particles: [],
  }));
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [temperature, setTemperature] = useState(15);
  const cells = simulation.cells;
  const particles = simulation.particles;
  const selectedCell = cells.find((cell) => cell.id === selectedId);
  const initializedCultureGeneration = useRef(cultureGeneration);
  const reportedExtinctionGeneration = useRef<number | null>(null);
  const temperatureMidpoint = (MIN_TEMPERATURE + MAX_TEMPERATURE) / 2;
  const thermometerColor =
    temperature > temperatureMidpoint
      ? '#e16a74'
      : temperature < temperatureMidpoint
        ? '#6c9bd7'
        : '#9aabc1';
  const thermometerFillHeight =
    (temperature / MAX_TEMPERATURE) * 22;

  const particlesRef = useRef(particles);

  useEffect(() => {
    particlesRef.current = particles;
  }, [particles]);

  useEffect(() => {
    if (
      !virusSeeds.length ||
      initializedCultureGeneration.current === cultureGeneration
    ) {
      return;
    }

    initializedCultureGeneration.current = cultureGeneration;
    reportedExtinctionGeneration.current = cultureGeneration;
    setSelectedId(null);
    setSimulation({
      cells: createInitialCells(virusSeeds),
      particles: [],
    });
  }, [cultureGeneration, virusSeeds]);

  useEffect(() => {
    if (cells.length > 0) {
      if (reportedExtinctionGeneration.current === cultureGeneration) {
        reportedExtinctionGeneration.current = null;
      }
      return;
    }

    if (
      !virusSeeds.length ||
      initializedCultureGeneration.current !== cultureGeneration ||
      reportedExtinctionGeneration.current === cultureGeneration
    ) {
      return;
    }

    reportedExtinctionGeneration.current = cultureGeneration;
    act('microscopePopulationExtinct', { generation: cultureGeneration });
  }, [act, cells.length, cultureGeneration, virusSeeds.length]);

  useEffect(() => {
    const interval = window.setInterval(() => {
      setSimulation((current) => ({
        ...current,
        cells: advanceCells(
          current.cells,
          temperature,
          foodReceiverAmount > 0,
        ),
      }));
    }, TICK_INTERVAL);

    return () => window.clearInterval(interval);
  }, [foodReceiverAmount, temperature]);

  useEffect(() => {
    let animationFrame = 0;
    let previousFrameTime: number | null = null;

    const animateParticles = (frameTime: number) => {
      if (previousFrameTime !== null && particlesRef.current.length > 0) {
        const elapsed = Math.min(frameTime - previousFrameTime, 50);
        const deltaScale = elapsed / TICK_INTERVAL;

        setSimulation((current) =>
          advanceReagentParticles(
            current.particles,
            current.cells,
            deltaScale,
          ),
        );
      }

      previousFrameTime = frameTime;
      animationFrame = window.requestAnimationFrame(animateParticles);
    };

    animationFrame = window.requestAnimationFrame(animateParticles);
    return () => window.cancelAnimationFrame(animationFrame);
  }, []);

  useEffect(() => {
    if (foodReceiverAmount <= 0 || cells.length === 0) {
      return;
    }

    const feedingInterval = window.setInterval(() => {
      if (particlesRef.current.length >= MAX_REAGENT_PARTICLES) {
        return;
      }

      const consumedAmount = Math.min(1, foodReceiverAmount);
      const foodPulse: MicroscopeAddedReagent[] = [
        {
          id: VIRUS_FOOD_REAGENT_ID,
          name: 'Питательная среда',
          amount: consumedAmount,
          color: '#ffffff',
          is_vaccine: false,
        },
      ];

      const newParticles = createReagentParticles(
        foodPulse,
        particlesRef.current,
      );
      if (!newParticles.length) {
        return;
      }

      act('feedMicroscopeCells');
      setSimulation((current) => ({
        cells: current.cells,
        particles: [...current.particles, ...newParticles],
      }));
    }, 3000);

    return () => window.clearInterval(feedingInterval);
  }, [act, cells.length, foodReceiverAmount]);

  const startReagentSimulation = () => {
    if (!addedReagents.length) {
      return;
    }

    const newParticles = createReagentParticles(
      addedReagents,
      particlesRef.current,
    );
    if (!newParticles.length) {
      return;
    }

    act('startMicroscopeSimulation');
    setSimulation((current) => ({
      ...current,
      particles: [...current.particles, ...newParticles],
    }));
  };

  return (
    <Window
      title="Вирусологический микроскоп"
      width={1120}
      height={640}
      resizable
    >
      <Window.Content allowWindowDrag={false}>
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '260px minmax(0, 1fr) 230px',
            gap: '8px',
            width: '100%',
            height: '100%',
            minHeight: 0,
            padding: '8px',
            boxSizing: 'border-box',
            backgroundColor: '#0c1422',
            color: '#e5eaf2',
          }}
        >
          <section
            style={{
              display: 'flex',
              flexDirection: 'column',
              minWidth: 0,
              minHeight: 0,
              padding: '9px',
              border: '1px solid #34465f',
              borderRadius: '4px',
              backgroundColor: '#111d2e',
              overflow: 'hidden',
            }}
          >
            <div style={{ fontWeight: 'bold', marginBottom: '5px' }}>
              Хранилище реагентов
            </div>
            <div style={{ color: '#aabbd0', fontSize: '11px', marginBottom: '8px' }}>
              {reagentStorageAmount.toFixed(1)} /{' '}
              {reagentStorageCapacity.toFixed(1)} ед. · {reagentStorageTypes}/
              {reagentTypeLimit} типа
            </div>
            <div
              style={{
                flex: 1,
                minHeight: 0,
                overflowY: 'auto',
                borderTop: '1px solid #293b54',
                paddingTop: '5px',
              }}
            >
              {availableReagents.length ? (
                availableReagents.map((reagent) => {
                  const queued = addedReagents.find(
                    (sample) => sample.id === reagent.id,
                  );
                  const queuedAmount = queued?.amount || 0;
                  return (
                    <div
                      key={reagent.id}
                      style={{
                        padding: '7px 0',
                        borderBottom: '1px solid #293b54',
                      }}
                    >
                      <div
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '5px',
                          marginBottom: '5px',
                        }}
                      >
                        <span
                          style={{
                            width: '8px',
                            height: '8px',
                            flexShrink: 0,
                            backgroundColor: reagent.is_vaccine
                              ? '#4b9cff'
                              : reagent.color,
                            borderRadius: '50%',
                          }}
                        />
                        <b style={{ flex: 1, minWidth: 0, overflowWrap: 'anywhere' }}>
                          {reagent.name}
                        </b>
                      </div>
                      <div style={{ color: '#aabbd0', fontSize: '11px', marginBottom: '5px' }}>
                        В автомате: {reagent.volume.toFixed(1)} ед.
                        {queuedAmount > 0
                          ? ' · выбрано: ' + queuedAmount.toFixed(1)
                          : ''}
                      </div>
                      <div style={{ display: 'flex', gap: '5px' }}>
                        <Button
                          compact
                          icon="plus"
                          disabled={queuedAmount >= reagent.volume}
                          onClick={() =>
                            act('addMicroscopeReagent', { id: reagent.id })
                          }
                        >
                          Добавить
                        </Button>
                        <Button
                          compact
                          icon="trash"
                          color="bad"
                          onClick={() =>
                            act('removeMicroscopeStoredReagent', {
                              id: reagent.id,
                            })
                          }
                        >
                          Удалить
                        </Button>
                      </div>
                    </div>
                  );
                })
              ) : (
                <div style={{ color: '#9eacbf', fontSize: '11px', padding: '6px 0' }}>
                  Хранилище пусто. Залейте реагент из открытой ёмкости или капельницы в автомат.
                </div>
              )}
            </div>
            <div
              style={{
                borderTop: '1px solid #34465f',
                paddingTop: '7px',
                marginTop: '7px',
              }}
            >
              <div style={{ fontWeight: 'bold', marginBottom: '5px' }}>
                Выбрано для микроскопа
              </div>
              {addedReagents.length ? (
                <div style={{ maxHeight: '90px', overflowY: 'auto' }}>
                  {addedReagents.map((reagent) => (
                    <div
                      key={reagent.id}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '5px',
                        fontSize: '11px',
                        paddingBottom: '3px',
                      }}
                    >
                      <span style={{ color: reagent.is_vaccine ? '#4b9cff' : reagent.color }}>
                        ●
                      </span>
                      <span style={{ flex: 1 }}>{reagent.name}</span>
                      <b>{reagent.amount.toFixed(1)}</b>
                    </div>
                  ))}
                </div>
              ) : (
                <div style={{ color: '#9eacbf', fontSize: '11px' }}>
                  Ничего не выбрано
                </div>
              )}
              <Button
                fluid
                mt={1}
                icon="play"
                disabled={!addedReagents.length}
                onClick={startReagentSimulation}
              >
                Запустить реагенты
              </Button>
              {particles.length > 0 && (
                <div
                  style={{
                    textAlign: 'center',
                    color: '#42e58d',
                    fontSize: '10px',
                    marginTop: '4px',
                  }}
                >
                  Частиц в поле: {particles.length}
                </div>
              )}
            </div>
          </section>

          <section
            style={{
              display: 'flex',
              flexDirection: 'column',
              minWidth: 0,
              minHeight: 0,
              gap: '7px',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                gap: '8px',
                color: '#dce6f3',
                fontSize: '12px',
              }}
            >
              <b>Клеточная культура</b>
              <span>
                Клеток: {cells.length} / {MAX_CELLS}
              </span>
              <span>
                Питание: {foodReceiverAmount.toFixed(1)} /{' '}
                {foodReceiverCapacity.toFixed(1)}
              </span>
            </div>
            <div
              style={{
                flex: 1,
                minHeight: 0,
                overflow: 'hidden',
                backgroundColor: '#101a2a',
                border: '1px solid #34465f',
                borderRadius: '4px',
              }}
            >
              <svg
                viewBox={'0 0 ' + AREA_WIDTH + ' ' + AREA_HEIGHT}
                width="100%"
                height="100%"
                preserveAspectRatio="xMidYMid meet"
                style={{ display: 'block', imageRendering: 'pixelated' }}
                aria-label="Движущиеся и делящиеся клетки вируса"
              >
                <rect
                  x="0"
                  y="0"
                  width={AREA_WIDTH}
                  height={AREA_HEIGHT}
                  fill="#101a2a"
                />
                {cells.map((cell) => {
                  if (cell.stage === 'splitting') {
                    const progress = clamp(cell.stageTicks / SPLIT_TICKS, 0, 1);
                    const offset = getSplitOffset(cell, progress);
                    const scale = 0.9 + progress * 0.1;
                    return (
                      <g key={cell.id}>
                        {renderCellSprite(
                          cell,
                          cell.x - offset.x,
                          cell.y - offset.y,
                          scale,
                          scale,
                          1,
                          selectedId === cell.id,
                          setSelectedId,
                          'left',
                        )}
                        {renderCellSprite(
                          cell,
                          cell.x + offset.x,
                          cell.y + offset.y,
                          scale,
                          scale,
                          1,
                          selectedId === cell.id,
                          setSelectedId,
                          'right',
                        )}
                      </g>
                    );
                  }
                  if (cell.stage === 'growing') {
                    const progress = clamp(cell.stageTicks / GROWTH_TICKS, 0, 1);
                    const scale = 1 + progress * 0.35;
                    return renderCellSprite(
                      cell,
                      cell.x,
                      cell.y,
                      scale,
                      scale,
                      1,
                      selectedId === cell.id,
                      setSelectedId,
                      'main',
                    );
                  }
                  if (cell.stage === 'stretching') {
                    const progress = clamp(
                      cell.stageTicks / STRETCH_TICKS,
                      0,
                      1,
                    );
                    return renderCellSprite(
                      cell,
                      cell.x,
                      cell.y,
                      1.35 + progress * 0.45,
                      1.35 - progress * 0.45,
                      1,
                      selectedId === cell.id,
                      setSelectedId,
                      'main',
                    );
                  }
                  if (cell.stage === 'dying') {
                    const progress = clamp(cell.stageTicks / DYING_TICKS, 0, 1);
                    const scale = 1 - progress * 0.4;
                    return renderCellSprite(
                      cell,
                      cell.x,
                      cell.y,
                      scale,
                      scale,
                      1 - progress,
                      selectedId === cell.id,
                      setSelectedId,
                      'main',
                    );
                  }
                  return renderCellSprite(
                    cell,
                    cell.x,
                    cell.y,
                    1,
                    1,
                    1,
                    selectedId === cell.id,
                    setSelectedId,
                    'main',
                  );
                })}
                {particles.map((particle) => (
                  <rect
                    key={particle.id}
                    x={Math.round(particle.x) - particle.radius}
                    y={Math.round(particle.y) - particle.radius}
                    width={particle.radius * 2}
                    height={particle.radius * 2}
                    fill={particle.color}
                    shapeRendering="crispEdges"
                    pointerEvents="none"
                  />
                ))}
              </svg>
            </div>
          </section>

          <section
            style={{
              display: 'flex',
              flexDirection: 'column',
              minWidth: 0,
              minHeight: 0,
              gap: '8px',
            }}
          >
            <div
              style={{
                padding: '10px',
                border: '1px solid #34465f',
                borderRadius: '4px',
                backgroundColor: '#111d2e',
              }}
            >
              <div style={{ fontWeight: 'bold', marginBottom: '8px' }}>
                Температура
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '9px' }}>
                <svg width="22" height="44" viewBox="0 0 22 44" aria-hidden="true">
                  <rect
                    x="7"
                    y="2"
                    width="8"
                    height="30"
                    rx="4"
                    fill="none"
                    stroke="#9aabc1"
                    strokeWidth="2"
                  />
                  <rect
                    x="10"
                    y={30 - thermometerFillHeight}
                    width="2"
                    height={thermometerFillHeight}
                    rx="1"
                    fill={thermometerColor}
                  />
                  <circle cx="11" cy="34" r="7" fill={thermometerColor} />
                  <circle cx="11" cy="34" r="3" fill="#f4d7da" />
                </svg>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: '19px', fontWeight: 'bold' }}>
                    {temperature}°C
                  </div>
                  <div style={{ fontSize: '10px', color: '#aabbd0' }}>
                    Комфорт: {COMFORTABLE_TEMP_MIN}–{COMFORTABLE_TEMP_MAX}°C
                  </div>
                </div>
              </div>
              <div style={{ marginTop: '10px' }}>
                <Slider
                  value={temperature}
                  minValue={MIN_TEMPERATURE}
                  maxValue={MAX_TEMPERATURE}
                  stepPixelSize={8}
                  onChange={(_event, value) => setTemperature(value)}
                />
              </div>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  fontSize: '9px',
                  color: '#91a1b5',
                }}
              >
                <span>0°C</span>
                <span>30°C</span>
              </div>
            </div>

            <div
              style={{
                flex: 1,
                minHeight: 0,
                overflowY: 'auto',
                padding: '10px',
                color: '#e5eaf2',
                backgroundColor: '#111d2e',
                border: '1px solid #34465f',
                borderRadius: '4px',
              }}
            >
              <div style={{ fontWeight: 'bold', marginBottom: '8px' }}>
                Характеристики клетки
              </div>
              {selectedCell ? (
                <>
                  <div
                    style={{
                      paddingBottom: '6px',
                      borderBottom: '1px solid #293b54',
                      fontSize: '12px',
                      fontWeight: 'bold',
                    }}
                  >
                    {selectedCell.name} №{selectedCell.id}
                  </div>
                  <StrengthMeter
                    label="Внешняя оболочка"
                    value={selectedCell.outerStrength}
                  />
                  <StrengthMeter
                    label="Внутренний слой"
                    value={selectedCell.innerStrength}
                  />
                  <StrengthMeter
                    label="Ядро"
                    value={selectedCell.nucleusStrength}
                  />
                  <div
                    style={{
                      marginTop: '12px',
                      paddingTop: '8px',
                      borderTop: '1px solid #293b54',
                      fontSize: '11px',
                    }}
                  >
                    <b>Питание для деления</b>
                    <div style={{ color: '#42e58d', marginTop: '4px' }}>
                      {selectedCell.food.toFixed(1)} / {FOOD_FOR_DIVISION} ед.
                    </div>
                  </div>
                </>
              ) : (
                <div style={{ color: '#9eacbf', fontSize: '11px' }}>
                  Выберите клетку в поле микроскопа, чтобы посмотреть её характеристики
                </div>
              )}
            </div>

          </section>
        </div>
      </Window.Content>
    </Window>
  );
};
