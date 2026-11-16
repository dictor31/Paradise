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
  microscope_reagents: string[];
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
type VisualPulseType = 'impact' | 'food' | 'damage';

type VirusCellData = {
  /** Legacy field read only when migrating an existing saved culture. */
  innerReagentId?: string | null;
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
  nucleusReagentId: string | null;
  outerStrength: number;
  innerStrength: number;
  nucleusStrength: number;
  stage: CellStage;
  stageTicks: number;
  membrane: number[];
  membraneVelocity: number[];
  visualPulse: number;
  visualPulseType: VisualPulseType;
  visualPulseAngle: number;
  divisionAngle: number;
  membranePhase: number;
}

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
  nucleusReagentId: string | null;
  outerStrength: number;
  innerStrength: number;
  nucleusStrength: number;
  stage: CellStage;
  stageTicks: number;
  membrane: number[];
  membraneVelocity: number[];
  visualPulse: number;
  visualPulseType: VisualPulseType;
  visualPulseAngle: number;
  divisionAngle: number;
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
    this.nucleusReagentId = properties.nucleusReagentId ?? properties.innerReagentId ?? null;
    this.outerStrength = properties.outerStrength;
    this.innerStrength = properties.innerStrength;
    this.nucleusStrength = properties.nucleusStrength;
    this.stage = properties.stage;
    this.stageTicks = properties.stageTicks;
    this.membrane = properties.membrane || createRestingMembrane();
    this.membraneVelocity =
      properties.membraneVelocity || createRestingMembrane();
    this.visualPulse = properties.visualPulse ?? 0;
    this.visualPulseType = properties.visualPulseType ?? 'impact';
    this.visualPulseAngle = properties.visualPulseAngle ?? 0;
    this.divisionAngle =
      properties.divisionAngle ??
      Math.atan2(properties.vy, properties.vx) + Math.PI / 2;
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

// A slightly faster visual step smooths membrane motion. The smaller delta
// keeps movement, particle travel, and biological timing at their previous rates.
const PHYSICS_INTERVAL = 32;
const BIOLOGICAL_DELTA_SCALE = 0.4;
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
const REAGENT_DAMAGE_PER_PARTICLE = 8;
const FOOD_FOR_DIVISION = 5;
const MAX_CELL_FOOD = 5;
const PARTICLES_PER_UNIT = 1;
const MAX_REAGENT_PARTICLES = 80;
const PARTICLE_RADIUS = 1;

// Each membrane segment behaves like a damped spring. Impact first stores
// energy as inward deformation; the spring then returns that energy over time.
const MEMBRANE_SPRING_STIFFNESS = 0.25;
const MEMBRANE_SPRING_DAMPING = 0.93;
const MEMBRANE_NEIGHBOR_STIFFNESS = 0.2;
const MEMBRANE_MAX_COMPRESSION = 16;
// Recoil is intentionally subtle and comes only from compressed membrane
// sections that are actually springing back toward their resting position.
const MEMBRANE_RECOIL_TRANSFER = 0.52;
const MEMBRANE_RECOIL_MAX_STEP = 0.13;
const CONTACT_POSITION_CORRECTION = 0.12;
const CONTACT_POSITION_MAX_CORRECTION = 0.45;
const CONTACT_VELOCITY_DAMPING = 0.72;
const MIN_COLLISION_IMPACT_SPEED = 0.1;

const GROWTH_TICKS = 28;
const STRETCH_TICKS = 30;
const SPLIT_TICKS = 28;
const DYING_TICKS = 60;

const clamp = (value: number, min: number, max: number) =>
  Math.max(min, Math.min(max, value));

const randomStrength = () => 88 + Math.round(Math.random() * 12);

const hashText = (value: string): number => {
  let hash = 2166136261;
  for (let index = 0; index < value.length; index++) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
};

// Visual traits belong to a virus strain, while contour phase varies slightly
// by cell ID. The profile is deterministic, so a culture looks consistent
// after saving, reconnecting, or dividing.
const getCellVisualProfile = (cell: VirusCell) => {
  const speciesHash = hashText(cell.name);
  const cellHash = (speciesHash ^ Math.imul(cell.id, 2654435761)) >>> 0;
  const surfaceStyle = speciesHash % 3;
  return {
    surfaceStyle,
    spikeCount: surfaceStyle === 0 ? 7 : surfaceStyle === 1 ? 10 : 12,
    spikeLength:
      surfaceStyle === 0
        ? 1.9
        : surfaceStyle === 1
          ? 2.8
          : 3.35,
    organelleCount: 4 + ((speciesHash >>> 8) % 4),
    shapePhase: (cellHash % 6283) / 1000,
    spikePhase: ((speciesHash >>> 16) % 6283) / 1000,
  };
};

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
    const reagents = seed.microscope_reagents || [];
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
      outerReagentId: reagents[0] || null,
      nucleusReagentId: reagents[1] || null,
      outerStrength: randomStrength(),
      innerStrength: randomStrength(),
      nucleusStrength: randomStrength(),
      stage: 'normal',
      stageTicks: 0,
      membrane: createRestingMembrane(),
      membraneVelocity: createRestingMembrane(),
      visualPulse: 0,
      visualPulseType: 'impact',
      visualPulseAngle: 0,
      divisionAngle: Math.random() * Math.PI * 2,
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
            // Older saved cultures used the second cure reagent for the inner layer.
            // Keep that reagent as the nucleus agent after the new two-layer mapping.
            nucleusReagentId: cell.nucleusReagentId || cell.innerReagentId || null,
            membrane:
              cell.membrane?.length === MEMBRANE_POINTS
                ? cell.membrane
                : createRestingMembrane(),
            membraneVelocity:
              cell.membraneVelocity?.length === MEMBRANE_POINTS
                ? cell.membraneVelocity
                : createRestingMembrane(),
            visualPulse: cell.visualPulse ?? 0,
            visualPulseType: cell.visualPulseType ?? 'impact',
            visualPulseAngle: cell.visualPulseAngle ?? 0,
            divisionAngle:
              cell.divisionAngle ??
              Math.atan2(cell.vy, cell.vx) + Math.PI / 2,
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
  const membraneVelocity =
    cell.membraneVelocity?.length === MEMBRANE_POINTS
      ? cell.membraneVelocity.slice()
      : createRestingMembrane();

  for (let index = 0; index < MEMBRANE_POINTS; index++) {
    const vertexAngle = (index / MEMBRANE_POINTS) * Math.PI * 2;
    const relativeAngle = vertexAngle - direction;
    const alignment = Math.cos(relativeAngle);
    const compression = Math.pow(Math.max(0, alignment), 1.15);
    // A broad contact patch lets the whole soft wall fold around an impact.
    const flank = Math.exp(-Math.pow((Math.abs(alignment) - 0.5) / 0.38, 2));
    membrane[index] = clamp(
      membrane[index] - pressure * compression * 1.0 + pressure * flank * 0.38,
      -MEMBRANE_MAX_COMPRESSION,
      5,
    );
    // Store enough impact energy in the membrane to produce a visible spring-back.
    membraneVelocity[index] = clamp(
      membraneVelocity[index] * 0.38 -
        pressure * compression * 0.56 +
        pressure * flank * 0.2,
      -8,
      8,
    );
  }

  return cell.with({
    membrane,
    membraneVelocity,
    visualPulse: Math.max(
      cell.visualPulse ?? 0,
      clamp(pressure / 1.4, 0.15, 1),
    ),
    visualPulseType: 'impact',
    visualPulseAngle: direction,
  });
};

const easeInOut = (value: number): number => {
  const progress = clamp(value, 0, 1);
  return progress * progress * (3 - 2 * progress);
};

const getCellDivisionProgress = (cell: VirusCell): number => {
  if (cell.stage === 'stretching') {
    return easeInOut(cell.stageTicks / STRETCH_TICKS) * 0.5;
  }
  if (cell.stage === 'splitting') {
    return 0.5 + easeInOut(cell.stageTicks / SPLIT_TICKS) * 0.5;
  }
  return 0;
};

const getCellCollisionRadius = (cell: VirusCell): number => {
  if (cell.stage === 'growing') {
    return cell.size * (1.08 + 0.27 * clamp(cell.stageTicks / GROWTH_TICKS, 0, 1));
  }
  if (cell.stage === 'stretching' || cell.stage === 'splitting') {
    // The collision hull follows the growing two-lobed outline, preventing
    // other cells from slipping through the future daughter-cell space.
    return cell.size * (1.28 + 0.9 * getCellDivisionProgress(cell));
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

  // Walls absorb the incoming motion and compress the membrane. They do not
  // reverse the cell's velocity; the membrane's recovery supplies the rebound.
  if (x < wallRadius + 4) {
    const penetration = wallRadius + 4 - x;
    x = wallRadius + 4;
    const impactSpeed = Math.max(0, -vx);
    vx = Math.max(0, vx);
    if (impactSpeed > MIN_COLLISION_IMPACT_SPEED) {
      updated = deformMembrane(
        updated,
        Math.PI,
        clamp(0.8 + penetration * 0.65 + impactSpeed * 1.25, 0.8, 8.0),
      );
    }
  } else if (x > AREA_WIDTH - wallRadius - 4) {
    const penetration = x - (AREA_WIDTH - wallRadius - 4);
    x = AREA_WIDTH - wallRadius - 4;
    const impactSpeed = Math.max(0, vx);
    vx = Math.min(0, vx);
    if (impactSpeed > MIN_COLLISION_IMPACT_SPEED) {
      updated = deformMembrane(
        updated,
        0,
        clamp(0.8 + penetration * 0.65 + impactSpeed * 1.25, 0.8, 8.0),
      );
    }
  }

  if (y < wallRadius + 4) {
    const penetration = wallRadius + 4 - y;
    y = wallRadius + 4;
    const impactSpeed = Math.max(0, -vy);
    vy = Math.max(0, vy);
    if (impactSpeed > MIN_COLLISION_IMPACT_SPEED) {
      updated = deformMembrane(
        updated,
        -Math.PI / 2,
        clamp(0.8 + penetration * 0.65 + impactSpeed * 1.25, 0.8, 8.0),
      );
    }
  } else if (y > AREA_HEIGHT - wallRadius - 4) {
    const penetration = y - (AREA_HEIGHT - wallRadius - 4);
    y = AREA_HEIGHT - wallRadius - 4;
    const impactSpeed = Math.max(0, vy);
    vy = Math.min(0, vy);
    if (impactSpeed > MIN_COLLISION_IMPACT_SPEED) {
      updated = deformMembrane(
        updated,
        Math.PI / 2,
        clamp(0.8 + penetration * 0.65 + impactSpeed * 1.25, 0.8, 8.0),
      );
    }
  }

  return updated.with({ x, y, vx, vy });
};

const resolveCellCollisions = (
  cells: VirusCell[],
  deltaScale: number,
): VirusCell[] => {
  const damping = Math.pow(MEMBRANE_SPRING_DAMPING, deltaScale);
  const resolved = cells.map((cell) => {
    const source =
      cell.membrane?.length === MEMBRANE_POINTS
        ? cell.membrane
        : createRestingMembrane();
    const sourceVelocity =
      cell.membraneVelocity?.length === MEMBRANE_POINTS
        ? cell.membraneVelocity
        : createRestingMembrane();
    const membrane: number[] = [];
    const membraneVelocity: number[] = [];
    let recoilX = 0;
    let recoilY = 0;

    // The membrane is a ring of damped springs. Neighbor tension smooths the
    // dent, while the outward spring velocity transfers its stored energy
    // into the cell's center of mass as a delayed, soft rebound.
    for (let index = 0; index < MEMBRANE_POINTS; index++) {
      const previous = source[(index + MEMBRANE_POINTS - 1) % MEMBRANE_POINTS];
      const next = source[(index + 1) % MEMBRANE_POINTS];
      const neighborMean = (previous + next) * 0.5;
      const springForce =
        -source[index] * MEMBRANE_SPRING_STIFFNESS +
        (neighborMean - source[index]) * MEMBRANE_NEIGHBOR_STIFFNESS;
      const velocity =
        (sourceVelocity[index] + springForce * deltaScale) * damping;
      const offset = clamp(
        source[index] + velocity * deltaScale,
        -MEMBRANE_MAX_COMPRESSION,
        3.5,
      );
      membrane.push(offset);
      membraneVelocity.push(velocity);

      // Ignore tiny resting oscillations and outward motion from uncompressed
      // areas: only a genuinely dented section may push the cell's center.
      if (source[index] < -0.25 && velocity > 0.06) {
        const compressionWeight = clamp((-source[index] - 0.25) / 5, 0, 1);
        const angle = (index / MEMBRANE_POINTS) * Math.PI * 2;
        recoilX -= Math.cos(angle) * velocity * compressionWeight;
        recoilY -= Math.sin(angle) * velocity * compressionWeight;
      }
    }

    // Several membrane points can release energy together. Cap the total
    // center impulse so the recoil feels like one soft push, not repeated kicks.
    const recoilLength = Math.hypot(recoilX, recoilY);
    const recoilScale =
      recoilLength > 0
        ? Math.min(
            MEMBRANE_RECOIL_TRANSFER * deltaScale,
            MEMBRANE_RECOIL_MAX_STEP / recoilLength,
          )
        : 0;

    return cell.with({
      membrane,
      membraneVelocity,
      vx: clamp(cell.vx + recoilX * recoilScale, -3.4, 3.4),
      vy: clamp(cell.vy + recoilY * recoilScale, -3.4, 3.4),
    });
  });

  // With at most ten cells this checks no more than 45 pairs per physics step.
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
      const rawDistance = Math.hypot(dx, dy);
      const distance = rawDistance || 0.001;
      const normalX = rawDistance > 0.001 ? dx / distance : 1;
      const normalY = rawDistance > 0.001 ? dy / distance : 0;
      const minimumDistance =
        getCellCollisionRadius(first) + getCellCollisionRadius(second);

      if (distance >= minimumDistance + 1.2) {
        continue;
      }

      const relativeVelocityX = second.vx - first.vx;
      const relativeVelocityY = second.vy - first.vy;
      const normalVelocity =
        relativeVelocityX * normalX + relativeVelocityY * normalY;
      const penetration = Math.max(0, minimumDistance - distance);
      const approachSpeed = Math.max(0, -normalVelocity);

      if (penetration <= 0 && approachSpeed <= 0.08) {
        continue;
      }

      const firstInverseMass = 1 / Math.max(1, first.size * first.size);
      const secondInverseMass = 1 / Math.max(1, second.size * second.size);
      const inverseMassTotal = firstInverseMass + secondInverseMass;

      // Only a small positional correction prevents deep overlap. Most of
      // the collision is absorbed by the deforming membrane, not by teleporting
      // the centers apart.
      if (penetration > 0) {
        const correction = Math.min(
          penetration * CONTACT_POSITION_CORRECTION,
          CONTACT_POSITION_MAX_CORRECTION,
        );
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

      // Absorb most of the incoming speed on the first contact. If the cells
      // are already resting against one another, do not keep injecting new
      // membrane impulses every simulation step.
      if (approachSpeed > MIN_COLLISION_IMPACT_SPEED) {
        const impulse =
          (approachSpeed * CONTACT_VELOCITY_DAMPING) / inverseMassTotal;
        first = first.with({
          vx: first.vx - impulse * firstInverseMass * normalX,
          vy: first.vy - impulse * firstInverseMass * normalY,
        });
        second = second.with({
          vx: second.vx + impulse * secondInverseMass * normalX,
          vy: second.vy + impulse * secondInverseMass * normalY,
        });

        const contactPressure = clamp(
          0.8 + approachSpeed * 1.2 + Math.min(penetration, 5) * 0.55,
          0.8,
          8.0,
        );
        const contactAngle = Math.atan2(normalY, normalX);
        first = deformMembrane(first, contactAngle, contactPressure);
        second = deformMembrane(
          second,
          contactAngle + Math.PI,
          contactPressure,
        );
      }

      resolved[firstIndex] = first;
      resolved[secondIndex] = second;
    }
  }

  return resolved;
};

const getSplitDirection = (cell: VirusCell) => ({
  x: Math.cos(cell.divisionAngle),
  y: Math.sin(cell.divisionAngle),
});

const getSplitOffset = (cell: VirusCell, progress: number) => {
  const direction = getSplitDirection(cell);
  const distance = cell.size * (0.28 + 0.9 * clamp(progress, 0, 1));
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
      visualPulse: Math.max(0, (cell.visualPulse ?? 0) - 0.035 * deltaScale),
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
            membraneVelocity: createRestingMembrane(),
            divisionAngle: updated.divisionAngle - Math.PI / 2,
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
              membraneVelocity: createRestingMembrane(),
              divisionAngle: updated.divisionAngle + Math.PI / 2,
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
        divisionAngle: Math.atan2(readyCell.cell.vy, readyCell.cell.vx) + Math.PI / 2,
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

      const contactAngle = Math.atan2(
        particle.y - touchedCell.y,
        particle.x - touchedCell.x,
      );

      if (particle.reagentId === VIRUS_FOOD_REAGENT_ID) {
        const food = clamp(
          touchedCell.food + particle.foodValue,
          0,
          MAX_CELL_FOOD,
        );
        nextCells[touchedCellIndex] = touchedCell.with({
          food,
          ...(food > touchedCell.food
            ? {
                visualPulse: 1,
                visualPulseType: 'food' as const,
                visualPulseAngle: contactAngle,
              }
            : {}),
        });
      } else if (particle.isVaccine && touchedCell.nucleusStrength > 0) {
        const nucleusStrength = Math.max(
          0,
          touchedCell.nucleusStrength - VACCINE_NUCLEUS_DAMAGE,
        );
        nextCells[touchedCellIndex] = touchedCell.with({
          nucleusStrength,
          visualPulse: 1,
          visualPulseType: 'damage',
          visualPulseAngle: contactAngle,
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
            touchedCell.outerStrength - REAGENT_DAMAGE_PER_PARTICLE,
          ),
          visualPulse: 1,
          visualPulseType: 'damage',
          visualPulseAngle: contactAngle,
        });
      } else if (
        touchedCell.nucleusReagentId !== null &&
        particle.reagentId === touchedCell.nucleusReagentId &&
        touchedCell.outerStrength <= 0 &&
        touchedCell.nucleusStrength > 0
      ) {
        const nucleusStrength = Math.max(
          0,
          touchedCell.nucleusStrength - REAGENT_DAMAGE_PER_PARTICLE,
        );
        nextCells[touchedCellIndex] = touchedCell.with({
          nucleusStrength,
          visualPulse: 1,
          visualPulseType: 'damage',
          visualPulseAngle: contactAngle,
          ...(nucleusStrength === 0
            ? { stage: 'dying' as const, stageTicks: 0 }
            : {}),
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

const getContourVariation = (cell: VirusCell, angle: number): number => {
  const profile = getCellVisualProfile(cell);
  return (
    Math.sin(angle * 2 + profile.shapePhase) * 1.05 +
    Math.sin(angle * 3 - profile.shapePhase * 0.63) * 0.58 +
    Math.cos(angle * 5 + profile.shapePhase * 0.37) * 0.28
  );
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
      Math.sin(phase * 1.3 + angle * 8) * 0.2 +
      Math.sin(phase * 6.2 + angle * 7 + cell.id * 2.4) * 0.12;
    const breathing =
      Math.sin(phase * 0.7 + angle * 2 + cell.id * 0.7) * 0.55;
    const strainShape =
      getContourVariation(cell, angle) * (baseRadius / 20) * 0.78;
    const radius =
      baseRadius +
      membrane[index] * deformationScale +
      strainShape +
      (membraneTwitch + breathing) * flutterScale;
    vertices.push({
      x: Math.cos(angle) * radius,
      y: Math.sin(angle) * radius,
    });
  }

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
) => {
  const profile = getCellVisualProfile(cell);
  const phase = cell.membranePhase ?? cell.id * 0.73;
  const damage = 1 - clamp(cell.outerStrength, 0, 100) / 100;
  const innerDamage = 1 - clamp(cell.innerStrength, 0, 100) / 100;
  const nucleusDamage = 1 - clamp(cell.nucleusStrength, 0, 100) / 100;
  const nucleusX = clamp(-cell.vx * 0.48 + Math.sin(phase * 0.7) * 0.45, -2.5, 2.5);
  const nucleusY = clamp(-cell.vy * 0.48 + Math.cos(phase * 0.61) * 0.45, -2.5, 2.5);
  const pulseColor =
    cell.visualPulseType === 'food'
      ? '#a9f1b0'
      : cell.visualPulseType === 'damage'
        ? '#ffb16e'
        : '#f3a0aa';
  const crackCount = damage > 0.12 ? Math.min(5, Math.ceil((damage - 0.12) * 5.8)) : 0;
  const spikeColor = profile.surfaceStyle === 1 ? '#d65b6d' : '#b8465a';
  const spikeHighlight = profile.surfaceStyle === 2 ? '#ffd0a0' : '#f18b91';

  return (
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
        transition: 'transform 32ms linear, opacity 32ms linear',
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
      {Array.from({ length: profile.spikeCount }, (_, index) => {
        const angle =
          (index / profile.spikeCount) * Math.PI * 2 + profile.spikePhase;
        const membraneIndex =
          Math.round((angle / (Math.PI * 2)) * MEMBRANE_POINTS) % MEMBRANE_POINTS;
        const localOffset = cell.membrane?.[membraneIndex] || 0;
        const restRadius =
          20 + localOffset + getContourVariation(cell, angle) * 0.78;
        const twitch = Math.sin(phase * 2.4 + index * 1.7) * 0.32;
        const radius = restRadius + twitch;
        const length =
          profile.spikeLength *
          (1 - damage * 0.72) *
          (0.82 + Math.sin(phase * 1.5 + index * 2.1) * 0.12);
        const baseX = Math.cos(angle) * radius;
        const baseY = Math.sin(angle) * radius;
        const tipX = Math.cos(angle) * (radius + length);
        const tipY = Math.sin(angle) * (radius + length);
        const tangentX = -Math.sin(angle) * 0.9;
        const tangentY = Math.cos(angle) * 0.9;

        return (
          <g key={index} opacity={0.92 - damage * 0.35}>
            <path
              d={
                `M ${baseX - tangentX} ${baseY - tangentY} ` +
                `L ${tipX} ${tipY} ` +
                `L ${baseX + tangentX} ${baseY + tangentY} Z`
              }
              fill={spikeColor}
              stroke="#7e293b"
              strokeWidth="0.45"
              strokeLinejoin="miter"
              shapeRendering="crispEdges"
            />
            <rect
              x={tipX - 0.48}
              y={tipY - 0.48}
              width="0.96"
              height="0.96"
              fill={spikeHighlight}
              shapeRendering="crispEdges"
            />
          </g>
        );
      })}
      <path
        d={createSoftMembranePath(cell, 20, 1, 1.15)}
        fill={
          cell.outerStrength > 65
            ? profile.surfaceStyle === 2
              ? '#842238'
              : '#741b2c'
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
        fill={innerDamage > 0.55 ? '#a64b5d' : '#df4b5b'}
        stroke="#f06a70"
        strokeWidth="0.65"
        strokeLinejoin="miter"
        opacity={0.94 - innerDamage * 0.18}
      />
      {Array.from({ length: crackCount }, (_, index) => {
        const angle =
          profile.shapePhase + index * 2.399963 + profile.spikePhase * 0.4;
        const startRadius = 14.7 + (index % 2) * 0.6;
        const middleRadius = startRadius + 1.5 + damage;
        const endRadius = 17.1 + damage * 1.2;
        const startX = Math.cos(angle) * startRadius;
        const startY = Math.sin(angle) * startRadius;
        const middleX = Math.cos(angle + 0.09) * middleRadius;
        const middleY = Math.sin(angle + 0.09) * middleRadius;
        const endX = Math.cos(angle - 0.07) * endRadius;
        const endY = Math.sin(angle - 0.07) * endRadius;
        return (
          <path
            key={index}
            d={`M ${startX} ${startY} L ${middleX} ${middleY} L ${endX} ${endY}`}
            fill="none"
            stroke="#34121f"
            strokeWidth={0.65 + damage * 0.7}
            strokeLinecap="square"
            opacity={0.35 + damage * 0.55}
            pointerEvents="none"
          />
        );
      })}
      {Array.from({ length: profile.organelleCount }, (_, index) => {
        const orbitAngle =
          phase * 0.34 +
          profile.shapePhase +
          (index / profile.organelleCount) * Math.PI * 2;
        const orbitRadius =
          9.2 + Math.sin(phase * 0.8 + index * 1.9) * 0.8;
        const organelleX = Math.cos(orbitAngle) * orbitRadius;
        const organelleY = Math.sin(orbitAngle) * orbitRadius;
        const organelleSize = 1.15 + ((index + profile.surfaceStyle) % 3) * 0.28;
        return (
          <g
            key={index}
            opacity={(0.62 + Math.sin(phase + index) * 0.12) * (1 - innerDamage * 0.58)}
          >
            <rect
              x={organelleX - organelleSize / 2}
              y={organelleY - organelleSize / 2}
              width={organelleSize}
              height={organelleSize}
              fill={
                innerDamage > 0.55
                  ? '#a66b72'
                  : index % 2
                    ? '#ffbd82'
                    : '#f58a80'
              }
              shapeRendering="crispEdges"
            />
            <rect
              x={organelleX + organelleSize * 0.12}
              y={organelleY - organelleSize * 0.48}
              width="0.65"
              height="0.65"
              fill="#ffe0a5"
              shapeRendering="crispEdges"
            />
          </g>
        );
      })}
      <g transform={`translate(${nucleusX} ${nucleusY})`}>
        <path
          d={createSoftMembranePath(cell, 7.2, 0.22, 0.04)}
          fill={
            nucleusDamage > 0.65
              ? '#49303f'
              : nucleusDamage > 0.3
                ? '#76243a'
                : '#641629'
          }
          stroke={nucleusDamage > 0.3 ? '#a74d5c' : 'none'}
          strokeWidth="0.55"
        />
        <path
          d="M -4 -4 H 0 V 0 H -4 Z"
          fill="#a92e43"
          opacity={0.9}
        />
        <rect
          x="1.5"
          y="-2.5"
          width="2"
          height="2"
          fill="#f28d83"
          opacity={0.8}
          shapeRendering="crispEdges"
        />
      </g>
      {cell.visualPulse > 0.015 && (
        <g pointerEvents="none">
          <circle
            r={21.5 + cell.visualPulse * 2.3}
            fill="none"
            stroke={pulseColor}
            strokeWidth={0.55 + cell.visualPulse * 0.75}
            strokeDasharray={cell.visualPulseType === 'impact' ? '4 3' : 'none'}
            opacity={cell.visualPulse * 0.72}
          />
          <path
            d={
              `M ${Math.cos(cell.visualPulseAngle) * 17.5} ${Math.sin(cell.visualPulseAngle) * 17.5} ` +
              `L ${Math.cos(cell.visualPulseAngle) * (23 + cell.visualPulse * 2)} ${Math.sin(cell.visualPulseAngle) * (23 + cell.visualPulse * 2)}`
            }
            stroke={pulseColor}
            strokeWidth="1.2"
            opacity={cell.visualPulse * 0.85}
          />
        </g>
      )}
    </g>
  );
};
const createDivisionMembranePath = (
  cell: VirusCell,
  progress: number,
  baseRadius: number,
  deformationScale: number,
): string => {
  const membrane =
    cell.membrane?.length === MEMBRANE_POINTS
      ? cell.membrane
      : createRestingMembrane();
  const centerOffset = 20 * (0.28 + 0.9 * progress);
  const leftRadius = Math.max(
    baseRadius * 0.62,
    baseRadius +
      membrane[MEMBRANE_POINTS / 2] * deformationScale +
      getContourVariation(cell, Math.PI) * (baseRadius / 20) * 0.5,
  );
  const rightRadius = Math.max(
    baseRadius * 0.62,
    baseRadius +
      membrane[0] * deformationScale +
      getContourVariation(cell, 0) * (baseRadius / 20) * 0.5,
  );
  const neckRadius = Math.max(
    1.2,
    baseRadius * (0.9 - 0.78 * progress) +
      (membrane[6] + membrane[18]) * 0.14 * deformationScale,
  );

  // One continuous dumbbell contour: the lobes swell outward while their
  // shared neck narrows gradually, instead of drawing two full cells together.
  return [
    `M 0 ${-neckRadius}`,
    `C ${centerOffset * 0.42} ${-neckRadius} ${centerOffset * 0.58} ${-rightRadius} ${centerOffset} ${-rightRadius}`,
    `C ${centerOffset + rightRadius * 0.55} ${-rightRadius} ${centerOffset + rightRadius} ${-rightRadius * 0.55} ${centerOffset + rightRadius} 0`,
    `C ${centerOffset + rightRadius} ${rightRadius * 0.55} ${centerOffset + rightRadius * 0.55} ${rightRadius} ${centerOffset} ${rightRadius}`,
    `C ${centerOffset * 0.58} ${rightRadius} ${centerOffset * 0.42} ${neckRadius} 0 ${neckRadius}`,
    `C ${-centerOffset * 0.42} ${neckRadius} ${-centerOffset * 0.58} ${leftRadius} ${-centerOffset} ${leftRadius}`,
    `C ${-centerOffset - leftRadius * 0.55} ${leftRadius} ${-centerOffset - leftRadius} ${leftRadius * 0.55} ${-centerOffset - leftRadius} 0`,
    `C ${-centerOffset - leftRadius} ${-leftRadius * 0.55} ${-centerOffset - leftRadius * 0.55} ${-leftRadius} ${-centerOffset} ${-leftRadius}`,
    `C ${-centerOffset * 0.58} ${-leftRadius} ${-centerOffset * 0.42} ${-neckRadius} 0 ${-neckRadius} Z`,
  ].join(' ');
};

const renderDividingCell = (
  cell: VirusCell,
  selected: boolean,
  onSelect: (id: number) => void,
) => {
  const progress = getCellDivisionProgress(cell);
  const profile = getCellVisualProfile(cell);
  const centerOffset = 20 * (0.28 + 0.9 * progress);
  const divisionRotation = (cell.divisionAngle * 180) / Math.PI;
  const phase = cell.membranePhase ?? cell.id * 0.73;
  const damage = 1 - clamp(cell.outerStrength, 0, 100) / 100;
  const innerDamage = 1 - clamp(cell.innerStrength, 0, 100) / 100;
  const nucleusDamage = 1 - clamp(cell.nucleusStrength, 0, 100) / 100;
  const neckStrength = 0.9 - 0.78 * progress;
  const leftNucleus = -centerOffset * 0.58;
  const rightNucleus = centerOffset * 0.58;
  const organellesPerLobe = Math.max(2, Math.ceil(profile.organelleCount / 2));
  const pulseColor =
    cell.visualPulseType === 'food'
      ? '#a9f1b0'
      : cell.visualPulseType === 'damage'
        ? '#ffb16e'
        : '#f3a0aa';

  return (
    <g
      key={cell.id + '-division'}
      transform={`translate(${cell.x} ${cell.y}) rotate(${divisionRotation}) scale(${cell.size / 20})`}
      className="VirusMicroscope__cell-sprite VirusMicroscope__cell-dividing"
      style={{ cursor: 'pointer' }}
      role="button"
      aria-label={'Выбрать делящуюся клетку ' + cell.name + ' №' + cell.id}
      onClick={() => onSelect(cell.id)}
    >
      {selected && (
        <ellipse
          rx={centerOffset + 26}
          ry="27"
          fill="none"
          stroke="#91ddc6"
          strokeWidth="1.5"
          strokeDasharray="3 3"
        />
      )}

      {Array.from({ length: profile.spikeCount * 2 }, (_, index) => {
        const side = index < profile.spikeCount ? -1 : 1;
        const spikeIndex = index % profile.spikeCount;
        const angle =
          (spikeIndex / profile.spikeCount) * Math.PI * 2 +
          profile.spikePhase;
        const radius = 19.5 * (1 - damage * 0.38);
        const x = side * centerOffset + Math.cos(angle) * radius;
        const y = Math.sin(angle) * radius;
        const length = profile.spikeLength * (1 - damage * 0.72);
        const tipX = side * centerOffset + Math.cos(angle) * (radius + length);
        const tipY = Math.sin(angle) * (radius + length);
        const tangentX = -Math.sin(angle) * 0.8;
        const tangentY = Math.cos(angle) * 0.8;

        return (
          <path
            key={index}
            d={
              `M ${x - tangentX} ${y - tangentY} L ${tipX} ${tipY} ` +
              `L ${x + tangentX} ${y + tangentY} Z`
            }
            fill={profile.surfaceStyle === 1 ? '#d65b6d' : '#b8465a'}
            stroke="#7e293b"
            strokeWidth="0.45"
            strokeLinejoin="miter"
            shapeRendering="crispEdges"
            opacity={0.9 - damage * 0.3}
          />
        );
      })}

      <path
        d={createDivisionMembranePath(cell, progress, 20, 1)}
        fill={damage > 0.65 ? '#626b7a' : '#741b2c'}
        stroke="#a83b4d"
        strokeWidth="1.55"
        strokeLinejoin="round"
      />
      <path
        d={createDivisionMembranePath(cell, progress, 15.5, 0.58)}
        fill={innerDamage > 0.55 ? '#a64b5d' : '#df4b5b'}
        stroke="#f06a70"
        strokeWidth="0.7"
        strokeLinejoin="round"
        opacity={0.94 - innerDamage * 0.18}
      />

      {[-1, 1].map((side) =>
        Array.from({ length: organellesPerLobe }, (_, index) => {
          const angle =
            phase * 0.32 +
            profile.shapePhase +
            (index / organellesPerLobe) * Math.PI * 2 +
            (side > 0 ? Math.PI * 0.3 : 0);
          const orbitRadius = 5.1 + Math.sin(phase * 0.7 + index * 2) * 0.65;
          const organelleX = side * centerOffset * 0.58 + Math.cos(angle) * orbitRadius;
          const organelleY = Math.sin(angle) * orbitRadius * 0.78;
          const organelleSize = 1.05 + ((index + profile.surfaceStyle) % 3) * 0.25;
          return (
            <rect
              key={side + '-' + index}
              x={organelleX - organelleSize / 2}
              y={organelleY - organelleSize / 2}
              width={organelleSize}
              height={organelleSize}
              fill={innerDamage > 0.55 ? '#a66b72' : index % 2 ? '#ffbd82' : '#f58a80'}
              opacity={(0.68 + Math.sin(phase + index) * 0.1) * (1 - innerDamage * 0.55)}
              shapeRendering="crispEdges"
            />
          );
        }),
      )}

      <g opacity={1 - nucleusDamage * 0.48}>
        <ellipse
          cx={leftNucleus}
          cy="0"
          rx={4.5 - nucleusDamage * 0.9}
          ry={4.1 - nucleusDamage * 0.7}
          fill={nucleusDamage > 0.65 ? '#49303f' : '#641629'}
          stroke="#a74d5c"
          strokeWidth="0.6"
        />
        <ellipse
          cx={rightNucleus}
          cy="0"
          rx={4.5 - nucleusDamage * 0.9}
          ry={4.1 - nucleusDamage * 0.7}
          fill={nucleusDamage > 0.65 ? '#49303f' : '#641629'}
          stroke="#a74d5c"
          strokeWidth="0.6"
        />
        <path
          d={`M ${leftNucleus + 4} -1 Q 0 -${2 + neckStrength * 3} ${rightNucleus - 4} -1 M ${leftNucleus + 4} 1 Q 0 ${2 + neckStrength * 3} ${rightNucleus - 4} 1`}
          fill="none"
          stroke="#f28d83"
          strokeWidth="0.7"
          opacity={0.75 - progress * 0.45}
        />
      </g>

      {damage > 0.3 && (
        <path
          d={`M ${-centerOffset - 10} -7 l 3 3 -2 4 4 3 M ${centerOffset + 8} -8 l -3 4 3 3 -2 4`}
          fill="none"
          stroke="#34121f"
          strokeWidth="0.9"
          opacity={damage * 0.72}
          pointerEvents="none"
        />
      )}

      {cell.visualPulse > 0.015 && (
        <ellipse
          rx={centerOffset + 22 + cell.visualPulse * 2}
          ry={22 + cell.visualPulse * 2}
          fill="none"
          stroke={pulseColor}
          strokeWidth="0.8"
          opacity={cell.visualPulse * 0.72}
          pointerEvents="none"
        />
      )}
    </g>
  );
};

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
                  if (
                    cell.stage === 'stretching' ||
                    cell.stage === 'splitting'
                  ) {
                    return renderDividingCell(
                      cell,
                      selectedId === cell.id,
                      setSelectedId,
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
                    style={{ transition: 'transform 32ms linear' }}
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
