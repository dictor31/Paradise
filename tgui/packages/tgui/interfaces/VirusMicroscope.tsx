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
  comfortable_temperature: number;
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
  microscope_sample_present: boolean;
  microscope_virus_seeds: MicroscopeVirusSeed[];
  microscope_culture_generation: number;
  microscope_temperature: number;
  microscope_simulation_initialized: boolean;
  microscope_simulation_cells: VirusCellData[];
  microscope_simulation_particles: ReagentParticle[];
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
  comfortTemperature: number;
  outerReagentId: string | null;
  innerReagentId: string | null;
  outerStrength: number;
  innerStrength: number;
  nucleusStrength: number;
  stage: CellStage;
  stageTicks: number;
  membrane: number[];
  membranePhase: number;
};

const MEMBRANE_POINTS = 24;
const createRestingMembrane = () => Array(MEMBRANE_POINTS).fill(0);

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
  comfortTemperature: number;
  outerReagentId: string | null;
  innerReagentId: string | null;
  outerStrength: number;
  innerStrength: number;
  nucleusStrength: number;
  stage: CellStage;
  stageTicks: number;
  membrane: number[];
  membranePhase: number;

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
    this.comfortTemperature = properties.comfortTemperature;
    this.outerReagentId = properties.outerReagentId;
    this.innerReagentId = properties.innerReagentId;
    this.outerStrength = properties.outerStrength;
    this.innerStrength = properties.innerStrength;
    this.nucleusStrength = properties.nucleusStrength;
    this.stage = properties.stage;
    this.stageTicks = properties.stageTicks;
    this.membrane = properties.membrane || createRestingMembrane();
    this.membranePhase = properties.membranePhase ?? this.id * 0.73;
  }

  with(changes: Partial<VirusCellData>): VirusCell {
    return new VirusCell({ ...this, ...changes });
  }
}

const AREA_WIDTH = 800;
const AREA_HEIGHT = 460;

const MAX_CELLS = 10;
const START_CELLS = 6;

const PHYSICS_INTERVAL = 40;
const BIOLOGICAL_DELTA_SCALE = 0.5;
const INNER_STRENGTH_DECAY_INTERVAL = 18;
const INNER_REPAIR_INTERVAL = 10;
const FOOD_PER_INNER_REPAIR = 0.1;
const NUCLEUS_STRENGTH_DECAY_INTERVAL = 54;
const COMFORTABLE_TEMP_TOLERANCE = 2;
const UNCOMFORTABLE_DAMAGE_INTERVAL = 8;
const UNCOMFORTABLE_DAMAGE_PER_TICK = 1;
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

const MEMBRANE_RELAXATION = 0.965;
const MEMBRANE_NEIGHBOR_STIFFNESS = 0.16;
const MEMBRANE_MAX_COMPRESSION = 11;
const CELL_RESTITUTION = 0.18;

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
      comfortTemperature: clamp(seed.comfortable_temperature ?? 15, MIN_TEMPERATURE, MAX_TEMPERATURE),
      outerReagentId: cures[0] || null,
      innerReagentId: cures[1] || null,
      outerStrength: randomStrength(),
      innerStrength: randomStrength(),
      nucleusStrength: randomStrength(),
      stage: 'normal',
      stageTicks: 0,
      membrane: createRestingMembrane(),
      membranePhase: Math.random() * Math.PI * 2,
    });
  });
};

const restoreMicroscopeSimulation = (
  data: VirusMicroscopeData,
  virusSeeds: MicroscopeVirusSeed[],
): MicroscopeSimulation => {
  if (data.microscope_simulation_initialized) {
    return {
      cells: (data.microscope_simulation_cells || []).map(
        (cell) =>
          new VirusCell({
            ...cell,
            outerReagentId: cell.outerReagentId || null,
            innerReagentId: cell.innerReagentId || null,
            membrane:
              cell.membrane?.length === MEMBRANE_POINTS
                ? cell.membrane
                : createRestingMembrane(),
            membranePhase: cell.membranePhase ?? cell.id * 0.73,
          }),
      ),
      particles: data.microscope_simulation_particles || [],
    };
  }

  return {
    cells: createInitialCells(virusSeeds),
    particles: [],
  };
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

const deformMembrane = (
  cell: VirusCell,
  direction: number,
  pressure: number,
): VirusCell => {
  if (pressure <= 0.001) {
    return cell;
  }

  const membrane =
    cell.membrane?.length === MEMBRANE_POINTS
      ? cell.membrane.slice()
      : createRestingMembrane();

  for (let index = 0; index < MEMBRANE_POINTS; index++) {
    const vertexAngle = (index / MEMBRANE_POINTS) * Math.PI * 2;
    const relativeAngle = vertexAngle - direction;
    const alignment = Math.cos(relativeAngle);
    const compression = Math.pow(Math.max(0, alignment), 2.25);
    // Displaced membrane material swells gently around the impact zone,
    // rather than producing a narrow, pinched dent.
    const flank = Math.exp(-Math.pow((Math.abs(alignment) - 0.48) / 0.24, 2));
    membrane[index] = clamp(
      membrane[index] - pressure * compression + pressure * flank * 0.22,
      -MEMBRANE_MAX_COMPRESSION,
      3.5,
    );
  }

  return cell.with({ membrane });
};

const getCellCollisionRadius = (cell: VirusCell): number => {
  if (cell.stage === 'growing') {
    return cell.size * (1.08 + 0.27 * clamp(cell.stageTicks / GROWTH_TICKS, 0, 1));
  }
  if (cell.stage === 'stretching') {
    const progress = clamp(cell.stageTicks / STRETCH_TICKS, 0, 1);
    return cell.size * (1.35 + 0.45 * progress);
  }
  if (cell.stage === 'splitting') {
    const progress = clamp(cell.stageTicks / SPLIT_TICKS, 0, 1);
    // Enclose both budding lobes so nearby cells cannot cut through the
    // widening division furrow before the daughters become independent.
    return cell.size * (1.13 + 1.05 * progress);
  }
  return cell.size;
};

const moveCell = (cell: VirusCell, deltaScale: number): VirusCell => {
  const wallRadius = getCellCollisionRadius(cell);
  // A gentle, deterministic drift keeps each culture from looking like a
  // collection of particles on perfectly straight trajectories.
  let vx =
    cell.vx +
    Math.sin(cell.age * 0.035 + cell.id * 2.1) * 0.035 * deltaScale;
  let vy =
    cell.vy +
    Math.cos(cell.age * 0.032 + cell.id * 1.7) * 0.035 * deltaScale;
  vx = clamp(vx, -2.8, 2.8);
  vy = clamp(vy, -2.8, 2.8);
  let x = cell.x + vx * deltaScale;
  let y = cell.y + vy * deltaScale;
  let updated = cell;

  if (x < wallRadius + 4) {
    x = wallRadius + 4;
    vx = Math.abs(vx) * 0.9;
    updated = deformMembrane(updated, Math.PI, 4.2);
  } else if (x > AREA_WIDTH - wallRadius - 4) {
    x = AREA_WIDTH - wallRadius - 4;
    vx = -Math.abs(vx) * 0.9;
    updated = deformMembrane(updated, 0, 4.2);
  }

  if (y < wallRadius + 4) {
    y = wallRadius + 4;
    vy = Math.abs(vy) * 0.9;
    updated = deformMembrane(updated, -Math.PI / 2, 4.2);
  } else if (y > AREA_HEIGHT - wallRadius - 4) {
    y = AREA_HEIGHT - wallRadius - 4;
    vy = -Math.abs(vy) * 0.9;
    updated = deformMembrane(updated, Math.PI / 2, 4.2);
  }

  return updated.with({ x, y, vx, vy });
};

const resolveCellCollisions = (
  cells: VirusCell[],
  deltaScale: number,
): VirusCell[] => {
  const relaxation = Math.pow(MEMBRANE_RELAXATION, deltaScale);
  const resolved = cells.map((cell) => {
    const source = cell.membrane || createRestingMembrane();
    const relaxed = source.map((value) => value * relaxation);
    // Adjacent membrane segments share tension, spreading each impact over
    // a wider, smoother patch instead of leaving a single sharp notch.
    const membrane = relaxed.map((value, index) => {
      const previous = relaxed[(index + MEMBRANE_POINTS - 1) % MEMBRANE_POINTS];
      const next = relaxed[(index + 1) % MEMBRANE_POINTS];
      const neighbors = (previous + next) * 0.5;
      return value * (1 - MEMBRANE_NEIGHBOR_STIFFNESS) +
        neighbors * MEMBRANE_NEIGHBOR_STIFFNESS;
    });
    return cell.with({ membrane });
  });

  // At most ten cells means only 45 pair checks per tick are needed.
  for (let firstIndex = 0; firstIndex < resolved.length; firstIndex++) {
    let first = resolved[firstIndex];
    if (first.stage === 'dying') {
      continue;
    }

    for (
      let secondIndex = firstIndex + 1;
      secondIndex < resolved.length;
      secondIndex++
    ) {
      let second = resolved[secondIndex];
      if (second.stage === 'dying') {
        continue;
      }

      const dx = second.x - first.x;
      const dy = second.y - first.y;
      const distance = Math.hypot(dx, dy) || 0.001;
      const firstRadius = getCellCollisionRadius(first);
      const secondRadius = getCellCollisionRadius(second);
      const minimumDistance = firstRadius + secondRadius;

      if (distance >= minimumDistance + 0.75) {
        continue;
      }

      const normalX = dx / distance;
      const normalY = dy / distance;
      const relativeVelocityX = second.vx - first.vx;
      const relativeVelocityY = second.vy - first.vy;
      const normalVelocity =
        relativeVelocityX * normalX + relativeVelocityY * normalY;
      const penetration = Math.max(0, minimumDistance - distance);

      if (penetration > 0) {
        const firstInverseMass = 1 / Math.max(1, first.size * first.size);
        const secondInverseMass = 1 / Math.max(1, second.size * second.size);
        const inverseMassTotal = firstInverseMass + secondInverseMass;
        const correction = penetration * 0.82;

        first = first.with({
          x:
            first.x -
            normalX * correction * (firstInverseMass / inverseMassTotal),
          y:
            first.y -
            normalY * correction * (firstInverseMass / inverseMassTotal),
        });
        second = second.with({
          x:
            second.x +
            normalX * correction * (secondInverseMass / inverseMassTotal),
          y:
            second.y +
            normalY * correction * (secondInverseMass / inverseMassTotal),
        });
      }

      let impactSpeed = 0;
      if (normalVelocity < 0) {
        const firstInverseMass = 1 / Math.max(1, first.size * first.size);
        const secondInverseMass = 1 / Math.max(1, second.size * second.size);
        const inverseMassTotal = firstInverseMass + secondInverseMass;
        const impulse =
          (-(1 + CELL_RESTITUTION) * normalVelocity) / inverseMassTotal;

        first = first.with({
          vx: first.vx - impulse * firstInverseMass * normalX,
          vy: first.vy - impulse * firstInverseMass * normalY,
        });
        second = second.with({
          vx: second.vx + impulse * secondInverseMass * normalX,
          vy: second.vy + impulse * secondInverseMass * normalY,
        });
        impactSpeed = -normalVelocity;
      }

      const contactPressure = clamp(
        0.65 + penetration * 0.95 + impactSpeed * 2.8,
        0,
        12,
      );
      const contactAngle = Math.atan2(normalY, normalX);
      first = deformMembrane(first, contactAngle, contactPressure);
      second = deformMembrane(
        second,
        contactAngle + Math.PI,
        contactPressure,
      );

      resolved[firstIndex] = first;
      resolved[secondIndex] = second;
    }
  }

  return resolved;
};

const getSplitDirection = (cell: VirusCell) => {
  const speed = Math.hypot(cell.vx, cell.vy);
  if (speed > 0.05) {
    return { x: -cell.vy / speed, y: cell.vx / speed };
  }

  const angle = cell.id * 2.399963;
  return { x: Math.cos(angle), y: Math.sin(angle) };
};

const getSplitOffset = (cell: VirusCell, progress: number) => {
  const direction = getSplitDirection(cell);
  const distance = cell.size * (0.35 + 0.83 * progress);
  return {
    x: direction.x * distance,
    y: direction.y * distance,
  };
};

const advanceCells = (
  cells: VirusCell[],
  temperature: number,
  foodAvailable: boolean,
  biologicalTick: boolean,
  deltaScale: number,
): VirusCell[] => {
  const next: VirusCell[] = [];
  const offspring: VirusCell[] = [];
  let nextId = cells.reduce((highest, cell) => Math.max(highest, cell.id), 0) + 1;
  for (const cell of cells) {
    const moved =
      cell.stage === 'dying' ? cell : moveCell(cell, deltaScale);
    let updated = moved.with({
      age: cell.age + (biologicalTick ? 1 : 0),
      membranePhase: (cell.membranePhase ?? 0) + 0.14 * deltaScale,
    });

    if (
      biologicalTick &&
      updated.stage !== 'dying' &&
      updated.age > 0
    ) {
      let outerStrength = updated.outerStrength;
      let innerStrength = updated.innerStrength;
      let nucleusStrength = updated.nucleusStrength;
      let cellFood = updated.food;
      const comfortable =
        Math.abs(temperature - updated.comfortTemperature) <=
        COMFORTABLE_TEMP_TOLERANCE;

      if (comfortable) {
        // Every maintenance interval consumes food to sustain the inner
        // layer, even when it is already at full strength. If food runs out,
        // the layer starts deteriorating again.
        if (
          cellFood > 0 &&
          updated.age % INNER_REPAIR_INTERVAL === 0
        ) {
          if (innerStrength < 100) {
            innerStrength = Math.min(100, innerStrength + 1);
          }
          cellFood = Math.max(0, cellFood - FOOD_PER_INNER_REPAIR);
        } else if (
          cellFood <= 0 &&
          innerStrength > 0 &&
          updated.age % INNER_STRENGTH_DECAY_INTERVAL === 0
        ) {
          innerStrength = Math.max(0, innerStrength - 1);
        }

        // With no food, the nucleus deteriorates only after the entire
        // inner layer has failed.
        if (
          innerStrength === 0 &&
          cellFood <= 0 &&
          nucleusStrength > 0 &&
          updated.age % NUCLEUS_STRENGTH_DECAY_INTERVAL === 0
        ) {
          nucleusStrength = Math.max(0, nucleusStrength - 1);
        }
      } else if (updated.age % UNCOMFORTABLE_DAMAGE_INTERVAL === 0) {
        // Outside this virus's temperature window, all three cell layers
        // deteriorate together. Nutrition cannot cancel environmental stress.
        outerStrength = Math.max(
          0,
          outerStrength - UNCOMFORTABLE_DAMAGE_PER_TICK,
        );
        innerStrength = Math.max(
          0,
          innerStrength - UNCOMFORTABLE_DAMAGE_PER_TICK,
        );
        nucleusStrength = Math.max(
          0,
          nucleusStrength - UNCOMFORTABLE_DAMAGE_PER_TICK,
        );
      }

      updated = updated.with({
        outerStrength,
        innerStrength,
        nucleusStrength,
        food: cellFood,
      });
    }

    if (
      biologicalTick &&
      updated.stage !== 'dying' &&
      updated.nucleusStrength === 0
    ) {
      updated = updated.with({ stage: 'dying', stageTicks: 0 });
    }

    if (!biologicalTick) {
      next.push(updated);
      continue;
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
        const splitDirection = getSplitDirection(updated);
        const directionX = splitDirection.x;
        const directionY = splitDirection.y;
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
            vx: updated.vx - directionX * 1.2,
            vy: updated.vy - directionY * 1.2,
            age: 0,
            food: 0,
            outerStrength: 100,
            innerStrength: 100,
            nucleusStrength: 100,
            stage: 'normal',
            stageTicks: 0,
            membrane: createRestingMembrane(),
            membranePhase: updated.membranePhase,
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
              vx: updated.vx + directionX * 1.2,
              vy: updated.vy + directionY * 1.2,
              age: 0,
              food: 0,
              outerStrength: 100,
              innerStrength: 100,
              nucleusStrength: 100,
              stage: 'normal',
              stageTicks: 0,
              membrane: createRestingMembrane(),
              membranePhase: updated.membranePhase + Math.PI,
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
    biologicalTick &&
    foodAvailable &&
    !hasDyingCell &&
    !divisionInProgress &&
    next.length < MAX_CELLS
  ) {
    const readyCell = next
      .map((cell, index) => ({ cell, index }))
      .filter(
        ({ cell }) =>
          cell.stage === 'normal' &&
          cell.food >= FOOD_FOR_DIVISION &&
          Math.abs(temperature - cell.comfortTemperature) <=
            COMFORTABLE_TEMP_TOLERANCE,
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

  return resolveCellCollisions(next, deltaScale);
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
          getCellCollisionRadius(cell) + particle.radius,
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

const createSoftMembranePath = (
  cell: VirusCell,
  baseRadius: number,
  deformationScale: number,
  flutterScale = 0,
): string => {
  const membrane =
    cell.membrane?.length === MEMBRANE_POINTS
      ? cell.membrane
      : createRestingMembrane();
  const vertices: { x: number; y: number }[] = [];

  for (let index = 0; index < MEMBRANE_POINTS; index++) {
    const angle = (index / MEMBRANE_POINTS) * Math.PI * 2;
    const phase = cell.membranePhase ?? cell.id * 0.73;
    const membraneTwitch =
      Math.sin(phase * 2.1 + angle * 3 + cell.id * 0.7) * 0.72 +
      Math.sin(phase * 3.4 - angle * 5 + cell.id * 1.3) * 0.38 +
      Math.sin(phase * 1.3 + angle * 8) * 0.2;
    const breathing =
      Math.sin(phase * 0.7 + angle * 2 + cell.id * 0.7) * 0.55;
    const radius =
      baseRadius +
      membrane[index] * deformationScale +
      (membraneTwitch + breathing) * flutterScale;
    vertices.push({
      x: Math.cos(angle) * radius,
      y: Math.sin(angle) * radius,
    });
  }

  // Quadratic curves through the membrane vertices keep the silhouette
  // rounded and organic even while individual segments are twitching.
  const midpoints = vertices.map((point, index) => {
    const next = vertices[(index + 1) % vertices.length];
    return { x: (point.x + next.x) / 2, y: (point.y + next.y) / 2 };
  });
  const last = midpoints[midpoints.length - 1];
  let path = `M ${last.x.toFixed(2)} ${last.y.toFixed(2)}`;

  for (let index = 0; index < vertices.length; index++) {
    const point = vertices[index];
    const midpoint = midpoints[index];
    path += ` Q ${point.x.toFixed(2)} ${point.y.toFixed(2)} ${midpoint.x.toFixed(2)} ${midpoint.y.toFixed(2)}`;
  }

  return path + ' Z';
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
    className="VirusMicroscope__cell-sprite"
    style={{
      cursor: 'pointer',
      opacity,
      transition: 'transform 40ms linear, opacity 40ms linear',
    }}
    role="button"
    aria-label={'Выбрать ' + cell.name + ' №' + cell.id}
    onClick={() => onSelect(cell.id)}
  >
    {selected && (
      <circle
        r="24"
        fill="none"
        stroke="#91ddc6"
        strokeWidth="1.5"
        strokeDasharray="3 3"
      />
    )}
    <path
      d={createSoftMembranePath(cell, 20, 1, 1.15)}
      fill={
        cell.outerStrength > 65
          ? '#741b2c'
          : cell.outerStrength > 30
            ? '#a34c35'
            : '#626b7a'
      }
      stroke="#a83b4d"
      strokeWidth="1.5"
      strokeLinejoin="miter"
      opacity={0.35 + cell.outerStrength / 150}
    />
    <path
      d={createSoftMembranePath(cell, 15.5, 0.58, 0.22)}
      fill="#df4b5b"
      stroke="#f06a70"
      strokeWidth="0.65"
      strokeLinejoin="miter"
      opacity={0.94}
    />
    <path
      d={createSoftMembranePath(cell, 7.2, 0.22, 0.04)}
      fill="#641629"
    />
    <path
      d="M -4 -4 H 0 V 0 H -4 Z"
      fill="#a92e43"
      opacity="0.9"
    />
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
    safeValue > 65
      ? 'var(--vm-accent)'
      : safeValue > 35
        ? 'var(--vm-warning)'
        : 'var(--vm-danger)';

  return (
    <div className="VirusMicroscope__meter">
      <div className="VirusMicroscope__meter-head">
        <span>{label}</span>
        <b>{safeValue}%</b>
      </div>
      <div className="VirusMicroscope__meter-track">
        <div
          className="VirusMicroscope__meter-fill"
          style={{ width: safeValue + '%', backgroundColor: barColor }}
        />
      </div>
    </div>
  );
};

export const VirusMicroscope = (_props: unknown) => {
  const { act, data } = useBackend<VirusMicroscopeData>();
  const availableReagents = data.microscope_available_reagents || [];
  const addedReagents = data.microscope_added_reagents || [];
  const microscopeSamplePresent = !!data.microscope_sample_present;
  const virusSeeds = data.microscope_virus_seeds || [];
  const cultureGeneration = data.microscope_culture_generation || 0;
  const foodReceiverAmount = data.microscope_food_amount || 0;
  const foodReceiverCapacity = data.microscope_food_capacity || 100;
  const reagentStorageAmount = data.microscope_reagent_storage_amount || 0;
  const reagentStorageCapacity =
    data.microscope_reagent_storage_capacity || 100;
  const reagentStorageTypes = data.microscope_reagent_storage_types || 0;
  const reagentStorageFill =
    reagentStorageCapacity > 0
      ? clamp((reagentStorageAmount / reagentStorageCapacity) * 100, 0, 100)
      : 0;
  const reagentTypeLimit = data.microscope_reagent_type_limit || 3;
  const [simulation, setSimulation] = useState<MicroscopeSimulation>(() =>
    restoreMicroscopeSimulation(data, virusSeeds),
  );
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [temperature, setTemperature] = useState(
    data.microscope_temperature ?? 15,
  );
  const [foodDose, setFoodDose] = useState(1);
  const cells = simulation.cells;
  const particles = simulation.particles;
  const selectedCell = cells.find((cell) => cell.id === selectedId);
  const initializedCultureGeneration = useRef(cultureGeneration);
  const reportedExtinctionGeneration = useRef<number | null>(null);
  const particlesRef = useRef(particles);
  const simulationRef = useRef(simulation);
  const temperatureRef = useRef(temperature);
  simulationRef.current = simulation;
  temperatureRef.current = temperature;

  useEffect(() => {
    particlesRef.current = particles;
  }, [particles]);

  useEffect(() => {
    if (!microscopeSamplePresent) {
      // The machine may remember a live culture, but it is not visible without
      // the exact sample that created it installed in the beaker slot.
      initializedCultureGeneration.current = -1;
      reportedExtinctionGeneration.current = null;
      setSelectedId(null);
      setSimulation((current) =>
        current.cells.length || current.particles.length
          ? { cells: [], particles: [] }
          : current,
      );
      return;
    }

    if (initializedCultureGeneration.current === cultureGeneration) {
      return;
    }

    initializedCultureGeneration.current = cultureGeneration;
    reportedExtinctionGeneration.current = null;
    setSelectedId(null);
    setSimulation(restoreMicroscopeSimulation(data, virusSeeds));
  }, [
    cultureGeneration,
    data.microscope_simulation_cells,
    data.microscope_simulation_initialized,
    data.microscope_simulation_particles,
    microscopeSamplePresent,
    virusSeeds,
  ]);

  useEffect(() => {
    const noViableCells =
      cells.length === 0 || cells.every((cell) => cell.stage === 'dying');

    if (!noViableCells) {
      if (reportedExtinctionGeneration.current === cultureGeneration) {
        reportedExtinctionGeneration.current = null;
      }
      return;
    }

    if (
      !microscopeSamplePresent ||
      !virusSeeds.length ||
      initializedCultureGeneration.current !== cultureGeneration ||
      reportedExtinctionGeneration.current === cultureGeneration
    ) {
      return;
    }

    // Mark the strain extinct as soon as every cell has entered its death
    // animation, not after the final fade-out frame.
    reportedExtinctionGeneration.current = cultureGeneration;
    act('microscopePopulationExtinct', { generation: cultureGeneration });
  }, [act, cells, cultureGeneration, microscopeSamplePresent, virusSeeds.length]);

  useEffect(() => {
    if (!microscopeSamplePresent) {
      return;
    }

    const saveSnapshot = () => {
      const current = simulationRef.current;
      act('saveMicroscopeState', {
        generation: cultureGeneration,
        temperature: temperatureRef.current,
        cells: current.cells.map((cell) => ({ ...cell })),
        particles: current.particles,
      });
    };

    // Give sample-insertion/restoration effects a moment to install the
    // restored snapshot before writing it back to the machine.
    const initialSave = window.setTimeout(saveSnapshot, 100);
    const saveInterval = window.setInterval(saveSnapshot, 500);
    return () => {
      window.clearTimeout(initialSave);
      window.clearInterval(saveInterval);
    };
  }, [act, cultureGeneration, microscopeSamplePresent]);

  const biologicalStep = useRef(true);

  useEffect(() => {
    const interval = window.setInterval(() => {
      const runBiology = biologicalStep.current;
      biologicalStep.current = !biologicalStep.current;

      setSimulation((current) => {
        if (!current.cells.length && !current.particles.length) {
          return current;
        }

        const nextCells = advanceCells(
          current.cells,
          temperature,
          foodReceiverAmount > 0,
          runBiology,
          BIOLOGICAL_DELTA_SCALE,
        );
        return advanceReagentParticles(
          current.particles,
          nextCells,
          BIOLOGICAL_DELTA_SCALE,
        );
      });
    }, PHYSICS_INTERVAL);

    return () => window.clearInterval(interval);
  }, [foodReceiverAmount, temperature]);

  useEffect(() => {
    if (foodReceiverAmount < foodDose || cells.length === 0) {
      return;
    }

    const feedingInterval = window.setInterval(() => {
      if (
        particlesRef.current.length + foodDose > MAX_REAGENT_PARTICLES
      ) {
        return;
      }

      const consumedAmount = foodDose;
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

      act('feedMicroscopeCells', { amount: foodDose });
      setSimulation((current) => ({
        cells: current.cells,
        particles: [...current.particles, ...newParticles],
      }));
    }, 3000);

    return () => window.clearInterval(feedingInterval);
  }, [act, cells.length, foodDose, foodReceiverAmount]);

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
      width={1220}
      height={700}
      resizable
    >
      <Window.Content allowWindowDrag={false}>
        <div className="VirusMicroscope">
          <section className="VirusMicroscope__reagents">
            <div className="VirusMicroscope__panel-title">
              Реагенты
              <span>РЕЗЕРВ · 3 СЛОТА</span>
            </div>
            <div className="VirusMicroscope__inventory-readout">
              {reagentStorageAmount.toFixed(1)} /{' '}
              {reagentStorageCapacity.toFixed(1)} ед. · {reagentStorageTypes}/
              {reagentTypeLimit} типа
            </div>
            <div className="VirusMicroscope__inventory-meter" aria-hidden="true">
              <div
                className="VirusMicroscope__inventory-meter-fill"
                style={{ width: reagentStorageFill + '%' }}
              />
            </div>
            <div className="VirusMicroscope__reagent-list">
              {availableReagents.length ? (
                availableReagents.map((reagent) => {
                  const queued = addedReagents.find(
                    (sample) => sample.id === reagent.id,
                  );
                  const queuedAmount = queued?.amount || 0;
                  return (
                    <div key={reagent.id} className="VirusMicroscope__reagent-row">
                      <div className="VirusMicroscope__reagent-heading">
                        <b className="VirusMicroscope__reagent-name">
                          {reagent.name}
                        </b>
                      </div>
                      <div className="VirusMicroscope__reagent-stock">
                        В автомате: {reagent.volume.toFixed(1)} ед.
                        {queuedAmount > 0
                          ? ' · выбрано: ' + queuedAmount.toFixed(1)
                          : ''}
                      </div>
                      <div className="VirusMicroscope__reagent-actions">
                        {[1, 5, 10].map((amount) => (
                          <Button
                            key={amount}
                            compact
                            className="VirusMicroscope__dose-button"
                            disabled={queuedAmount + amount > reagent.volume + 0.001}
                            onClick={() =>
                              act('addMicroscopeReagent', {
                                id: reagent.id,
                                amount,
                              })
                            }
                          >
                            {amount}
                          </Button>
                        ))}
                        <Button
                          compact
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
                <div className="VirusMicroscope__empty-state">
                  Хранилище пусто. Залейте реагент из открытой ёмкости или капельницы в автомат.
                </div>
              )}
            </div>
            <div className="VirusMicroscope__assay">
              <div className="VirusMicroscope__assay-heading">
                <div className="VirusMicroscope__panel-title">
                  Выбрано для введения
                  <span>{addedReagents.length} / {reagentTypeLimit}</span>
                </div>
                <Button
                  compact
                  className="VirusMicroscope__reset-button"
                  disabled={!addedReagents.length}
                  onClick={() => act('clearMicroscopeReagents')}
                >
                  Сбросить
                </Button>
              </div>
              {addedReagents.length ? (
                <div className="VirusMicroscope__assay-list">
                  {addedReagents.map((reagent) => (
                    <div key={reagent.id} className="VirusMicroscope__assay-row">
                      <span className="VirusMicroscope__assay-name">{reagent.name}</span>
                      <b>{reagent.amount.toFixed(1)}</b>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="VirusMicroscope__empty-state">
                  Порция не набрана
                </div>
              )}
              <Button
                fluid
                mt={1}
                disabled={!addedReagents.length}
                onClick={startReagentSimulation}
              >
                Подать реагенты
              </Button>
              <div className="VirusMicroscope__particle-count">
                ЧАСТИЦ В КАМЕРЕ <b>{particles.length}</b>
              </div>
            </div>
          </section>

          <section className="VirusMicroscope__culture">
            <div className="VirusMicroscope__culture-header">
              <div>
                <div className="VirusMicroscope__culture-title">Культура</div>
                <div className="VirusMicroscope__culture-subtitle">
                  НАБЛЮДЕНИЕ В РЕАЛЬНОМ ВРЕМЕНИ
                </div>
              </div>
              <div className="VirusMicroscope__culture-readouts">
                <span className="VirusMicroscope__cell-count">
                  КЛЕТКИ <b>{cells.length}<i> / {MAX_CELLS}</i></b>
                </span>
              <div className="VirusMicroscope__food-control">
                <span className="VirusMicroscope__food-readout">
                  ПИТАНИЕ <b>{foodReceiverAmount.toFixed(1)}</b>
                  <i> / {foodReceiverCapacity.toFixed(0)}</i>
                </span>
                <span className="VirusMicroscope__dose-label">ПОДАЧА</span>
                {[1, 2, 3, 4, 5].map((amount) => (
                  <Button
                    key={amount}
                    compact
                    className={
                      foodDose === amount
                        ? 'VirusMicroscope__dose-button is-active'
                        : 'VirusMicroscope__dose-button'
                    }
                    onClick={() => setFoodDose(amount)}
                  >
                    {amount}
                  </Button>
                ))}
              </div>
              </div>
            </div>
            <div className="VirusMicroscope__canvas">
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
                  fill="#172a2d"
                />
                <defs>
                  <pattern
                    id="virus-microscope-grid"
                    width="40"
                    height="40"
                    patternUnits="userSpaceOnUse"
                  >
                    <path
                      d="M 40 0 L 0 0 0 40"
                      fill="none"
                      stroke="#8aa99d"
                      strokeWidth="0.65"
                      opacity="0.16"
                    />
                  </pattern>
                </defs>
                <rect
                  x="0"
                  y="0"
                  width={AREA_WIDTH}
                  height={AREA_HEIGHT}
                  fill="url(#virus-microscope-grid)"
                />
                {cells.map((cell) => {
                  if (cell.stage === 'splitting') {
                    const progress = clamp(cell.stageTicks / SPLIT_TICKS, 0, 1);
                    const offset = getSplitOffset(cell, progress);
                    const scale = 0.78 + progress * 0.22;
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
                  <g
                    key={particle.id}
                    className="VirusMicroscope__particle"
                    transform={`translate(${particle.x} ${particle.y})`}
                    style={{ transition: 'transform 40ms linear' }}
                    pointerEvents="none"
                  >
                    <rect
                      x={-particle.radius}
                      y={-particle.radius}
                      width={particle.radius * 2}
                      height={particle.radius * 2}
                      fill={particle.color}
                      shapeRendering="crispEdges"
                    />
                  </g>
                ))}
              </svg>
            </div>
          </section>

          <section className="VirusMicroscope__sidebar">
            <div className="VirusMicroscope__temperature">
              <div className="VirusMicroscope__panel-title">
                Температура
                <span>ТЕРМОКОНТРОЛЬ</span>
              </div>
              <div className="VirusMicroscope__temperature-reading">
                <div className="VirusMicroscope__temperature-value">
                  <strong>{temperature}°C</strong>
                  <span className="VirusMicroscope__temperature-note">
                    {selectedCell
                      ? 'Оптимум вируса: ' +
                        selectedCell.comfortTemperature +
                        '°C (±' +
                        COMFORTABLE_TEMP_TOLERANCE +
                        '°C)'
                      : 'Выберите клетку, чтобы увидеть её температурный оптимум'}
                  </span>
                </div>
              </div>
              <div className="VirusMicroscope__temperature-slider">
                <Slider
                  value={temperature}
                  minValue={MIN_TEMPERATURE}
                  maxValue={MAX_TEMPERATURE}
                  stepPixelSize={8}
                  onChange={(_event, value) => {
                    setTemperature(value);
                    act('setMicroscopeTemperature', { temperature: value });
                  }}
                />
              </div>
              <div className="VirusMicroscope__temperature-scale">
                <span>0°C</span>
                <span>30°C</span>
              </div>
            </div>

            <div className="VirusMicroscope__cell-details">
              <div className="VirusMicroscope__panel-title">
                Параметры клетки
                <span>АНАЛИЗ</span>
              </div>
              {selectedCell ? (
                <>
                  <div className="VirusMicroscope__selected-cell-name">
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
                  <div className="VirusMicroscope__division">
                    <b>Питательный резерв</b>
                    <div className="VirusMicroscope__division-value">
                      {selectedCell.food.toFixed(1)} / {FOOD_FOR_DIVISION} ед.
                    </div>
                    <div className="VirusMicroscope__reserve-track">
                      <div
                        style={{
                          width: (selectedCell.food / MAX_CELL_FOOD) * 100 + '%',
                        }}
                      />
                    </div>
                    <div className="VirusMicroscope__reserve-note">
                      Расходуется на восстановление внутреннего слоя и деление
                    </div>
                  </div>
                </>
              ) : (
                <div className="VirusMicroscope__empty-state">
                  Выберите клетку на поле, чтобы открыть её показатели
                </div>
              )}
            </div>

          </section>
        </div>
      </Window.Content>
    </Window>
  );
};
