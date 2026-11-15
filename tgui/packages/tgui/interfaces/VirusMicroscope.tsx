import { Button } from 'tgui-core/components';
import { useBackend } from '../backend';
import { useEffect, useState } from 'react';
import { Window } from '../layouts';

type MicroscopeReagent = {
  id: string;
  name: string;
  volume: number;
};

type MicroscopeAddedReagent = {
  id: string;
  name: string;
  amount: number;
};

type VirusMicroscopeData = {
  microscope_available_reagents: MicroscopeReagent[];
  microscope_added_reagents: MicroscopeAddedReagent[];
};

type ReagentParticle = {
  id: number;
  reagentId: string;
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

const MIN_CELLS = 5;
const MAX_CELLS = 10;
const START_CELLS = 6;

const TICK_INTERVAL = 80;
const DIVISION_AGE = 240;
const STRENGTH_DECAY_INTERVAL = 18;
const UNCOMFORTABLE_TEMP_DECAY_INTERVAL = 5;
const COMFORTABLE_TEMP_MIN = 10;
const COMFORTABLE_TEMP_MAX = 20;
const MIN_TEMPERATURE = 0;
const MAX_TEMPERATURE = 30;
const WATER_REAGENT_ID = 'water';
const WATER_SHELL_DAMAGE = 8;
const PARTICLES_PER_UNIT = 8;
const MAX_REAGENT_PARTICLES = 80;
const PARTICLE_RADIUS = 3;

const GROWTH_TICKS = 28;
const STRETCH_TICKS = 24;
const SPLIT_TICKS = 18;
const DYING_TICKS = 20;

const clamp = (value: number, min: number, max: number) =>
  Math.max(min, Math.min(max, value));

const randomStrength = () => 88 + Math.round(Math.random() * 12);

const createInitialCells = (): VirusCell[] => {
  const positions = [
    [110, 90],
    [285, 185],
    [480, 95],
    [680, 160],
    [185, 355],
    [535, 345],
  ];

  return positions.slice(0, START_CELLS).map(([x, y], index) => {
    const id = index + 1;
    return new VirusCell({
      id,
      name: 'Красный вирус',
      x,
      y,
      vx: (Math.random() - 0.5) * 2.2,
      vy: (Math.random() - 0.5) * 2.2,
      age: 0,
      size: 17 + Math.round(Math.random() * 3),
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
): ReagentParticle[] => {
  const particles: ReagentParticle[] = [];
  let nextId = 1;

  for (const reagent of reagents) {
    const count = Math.min(
      MAX_REAGENT_PARTICLES - particles.length,
      Math.max(1, Math.floor(reagent.amount * PARTICLES_PER_UNIT)),
    );

    for (let index = 0; index < count; index++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 1.4 + Math.random() * 1.8;
      particles.push({
        id: nextId++,
        reagentId: reagent.id,
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
): VirusCell[] => {
  const next: VirusCell[] = [];
  const offspring: VirusCell[] = [];
  let nextId = cells.reduce((highest, cell) => Math.max(highest, cell.id), 0) + 1;
  const comfortable =
    temperature >= COMFORTABLE_TEMP_MIN &&
    temperature <= COMFORTABLE_TEMP_MAX;
  const decayInterval = comfortable
    ? STRENGTH_DECAY_INTERVAL
    : UNCOMFORTABLE_TEMP_DECAY_INTERVAL;
  const alreadyDying = cells.filter((cell) => cell.stage === 'dying').length;
  let deathSlots = comfortable
    ? Math.max(0, cells.length - MIN_CELLS - alreadyDying)
    : cells.length - alreadyDying;

  for (const cell of cells) {
    const moved = cell.stage === 'dying' ? cell : moveCell(cell);
    let updated = moved.with({ age: cell.age + 1 });

    if (
      updated.stage !== 'dying' &&
      updated.age > 0 &&
      updated.age % decayInterval === 0
    ) {
      let innerStrength = updated.innerStrength;
      let nucleusStrength = updated.nucleusStrength;

      // Стареет сначала внутренний слой, и только после его разрушения — ядро.
      // В комфортной среде ядро не опускается ниже 1%, пока популяция на минимуме.
      if (innerStrength > 0) {
        innerStrength = Math.max(0, innerStrength - 1);
      } else if (nucleusStrength > 0 && (!comfortable || deathSlots > 0)) {
        nucleusStrength = Math.max(0, nucleusStrength - 1);
      }

      updated = updated.with({ innerStrength, nucleusStrength });
    }

    if (
      updated.stage !== 'dying' &&
      updated.innerStrength === 0 &&
      updated.nucleusStrength === 0 &&
      deathSlots > 0
    ) {
      updated = updated.with({ stage: 'dying', stageTicks: 0 });
      deathSlots--;
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
              outerStrength: Math.max(
                25,
                updated.outerStrength - Math.round(Math.random() * 4),
              ),
              innerStrength: Math.max(
                25,
                updated.innerStrength - Math.round(Math.random() * 4),
              ),
              nucleusStrength: Math.max(
                25,
                updated.nucleusStrength - Math.round(Math.random() * 4),
              ),
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
    !hasDyingCell &&
    !divisionInProgress &&
    next.length < MAX_CELLS
  ) {
    const readyCell = next
      .map((cell, index) => ({ cell, index }))
      .filter(
        ({ cell }) =>
          cell.stage === 'normal' && cell.age >= DIVISION_AGE,
      )
      .sort((a, b) => b.cell.age - a.cell.age)[0];

    if (readyCell) {
      next[readyCell.index] = readyCell.cell.with({
        stage: 'growing',
        stageTicks: 0,
      });
    }
  }

  return next;
};

const advanceReagentParticles = (
  particles: ReagentParticle[],
  cells: VirusCell[],
): MicroscopeSimulation => {
  const nextParticles: ReagentParticle[] = [];
  const damageByCell = new Map<number, number>();

  for (const particle of particles) {
    let x = particle.x + particle.vx;
    let y = particle.y + particle.vy;
    let vx = particle.vx;
    let vy = particle.vy;

    if (x < particle.radius || x > AREA_WIDTH - particle.radius) {
      vx *= -1;
      x = clamp(x, particle.radius, AREA_WIDTH - particle.radius);
    }
    if (y < particle.radius || y > AREA_HEIGHT - particle.radius) {
      vy *= -1;
      y = clamp(y, particle.radius, AREA_HEIGHT - particle.radius);
    }

    const touchedCell = cells.find(
      (cell) =>
        cell.stage !== 'dying' &&
        Math.hypot(x - cell.x, y - cell.y) <= cell.size + particle.radius,
    );

    if (touchedCell && particle.reagentId === WATER_REAGENT_ID) {
      damageByCell.set(
        touchedCell.id,
        (damageByCell.get(touchedCell.id) || 0) + WATER_SHELL_DAMAGE,
      );
      continue;
    }

    nextParticles.push({ ...particle, x, y, vx, vy });
  }

  const damagedCells = cells.map((cell) => {
    const damage = damageByCell.get(cell.id) || 0;
    if (!damage) {
      return cell;
    }

    return cell.with({
      outerStrength: Math.max(0, cell.outerStrength - damage),
    });
  });

  return { cells: damagedCells, particles: nextParticles };
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
  const [simulation, setSimulation] = useState<MicroscopeSimulation>(() => ({
    cells: createInitialCells(),
    particles: [],
  }));
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [temperature, setTemperature] = useState(15);
  const cells = simulation.cells;
  const particles = simulation.particles;
  const selectedCell = cells.find((cell) => cell.id === selectedId);
  const temperatureMidpoint = (MIN_TEMPERATURE + MAX_TEMPERATURE) / 2;
  const thermometerColor =
    temperature > temperatureMidpoint
      ? '#e16a74'
      : temperature < temperatureMidpoint
        ? '#6c9bd7'
        : '#9aabc1';
  const thermometerFillHeight =
    (temperature / MAX_TEMPERATURE) * 22;

  useEffect(() => {
    const interval = window.setInterval(() => {
      setSimulation((current) => {
        const movedCells = advanceCells(current.cells, temperature);
        return advanceReagentParticles(current.particles, movedCells);
      });
    }, TICK_INTERVAL);

    return () => window.clearInterval(interval);
  }, [temperature]);

  const startReagentSimulation = () => {
    setSimulation((current) => ({
      ...current,
      particles: createReagentParticles(addedReagents),
    }));
  };

  return (
    <Window
      title="Вирусологический микроскоп"
      width={820}
      height={520}
      resizable
    >
      <Window.Content>
        <div
          style={{
            position: 'relative',
            width: '100%',
            height: '460px',
            overflow: 'hidden',
            backgroundColor: '#101a2a',
            border: '1px solid #293b54',
          }}
        >
          <svg
            viewBox={'0 0 ' + AREA_WIDTH + ' ' + AREA_HEIGHT}
            width="100%"
            height="100%"
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
              <circle
                key={particle.id}
                cx={particle.x}
                cy={particle.y}
                r={particle.radius}
                fill="#42e58d"
                stroke="#c2ffdc"
                strokeWidth="1"
                pointerEvents="none"
              />
            ))}
          </svg>

          <div
            style={{
              position: 'absolute',
              top: '10px',
              left: '10px',
              padding: '5px 8px',
              color: '#dce6f3',
              backgroundColor: 'rgba(8, 15, 27, 0.88)',
              border: '1px solid #293b54',
              borderRadius: '3px',
              fontSize: '11px',
              pointerEvents: 'none',
            }}
          >
            Клеток: {cells.length} / {MAX_CELLS}
          </div>

          <div
            style={{
              position: 'absolute',
              top: '10px',
              right: '10px',
              width: '210px',
              padding: '10px',
              color: '#e5eaf2',
              backgroundColor: 'rgba(8, 15, 27, 0.94)',
              border: '1px solid #51627a',
              borderRadius: '4px',
              pointerEvents: 'auto',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '9px',
              }}
            >
              <svg
                width="22"
                height="44"
                viewBox="0 0 22 44"
                aria-hidden="true"
              >
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
                <circle
                  cx="11"
                  cy="34"
                  r="7"
                  fill={thermometerColor}
                />
                <circle cx="11" cy="34" r="3" fill="#f4d7da" />
              </svg>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: '11px', color: '#b8c6d8' }}>
                  Температура среды
                </div>
                <div style={{ fontSize: '17px', fontWeight: 'bold' }}>
                  {temperature}°C
                </div>
              </div>
            </div>
            <input
              aria-label="Настройка температуры среды"
              type="range"
              min={MIN_TEMPERATURE}
              max={MAX_TEMPERATURE}
              step="1"
              value={temperature}
              onChange={(event) =>
                setTemperature(Number(event.currentTarget.value))
              }
              style={{
                width: '100%',
                margin: '8px 0 2px',
                accentColor: thermometerColor,
                cursor: 'pointer',
              }}
            />
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
              position: 'absolute',
              left: '10px',
              bottom: '10px',
              width: '250px',
              maxHeight: '175px',
              padding: '9px',
              color: '#e5eaf2',
              backgroundColor: 'rgba(8, 15, 27, 0.96)',
              border: '1px solid #51627a',
              borderRadius: '4px',
              pointerEvents: 'auto',
              overflow: 'hidden',
              fontSize: '11px',
            }}
          >
            <div
              style={{
                fontWeight: 'bold',
                paddingBottom: '5px',
                borderBottom: '1px solid #293b54',
              }}
            >
              Реагенты в бикере
            </div>
            <div style={{ maxHeight: '58px', overflowY: 'auto' }}>
              {availableReagents.length ? (
                availableReagents.map((reagent) => (
                  <div
                    key={reagent.id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      gap: '6px',
                      paddingTop: '4px',
                    }}
                  >
                    <span>
                      {reagent.name} ({reagent.volume.toFixed(1)})
                    </span>
                    <Button
                      icon="plus"
                      compact
                      onClick={() =>
                        act('addMicroscopeReagent', { id: reagent.id })
                      }
                    >
                      Добавить порцию
                    </Button>
                  </div>
                ))
              ) : (
                <div style={{ color: '#9eacbf', padding: '5px 0' }}>
                  Установите бикер с реагентами в Пандемик
                </div>
              )}
            </div>
            <div
              style={{
                marginTop: '5px',
                paddingTop: '5px',
                borderTop: '1px solid #293b54',
              }}
            >
              <div style={{ color: '#b8c6d8', marginBottom: '3px' }}>
                Добавлено в микроскоп
              </div>
              {addedReagents.length ? (
                <div style={{ maxHeight: '35px', overflowY: 'auto' }}>
                  {addedReagents.map((reagent) => (
                    <div key={reagent.id}>
                      <span style={{ color: '#42e58d' }}>●</span>{' '}
                      {reagent.name}: {reagent.amount.toFixed(1)} ед.
                    </div>
                  ))}
                </div>
              ) : (
                <div style={{ color: '#9eacbf', marginBottom: '4px' }}>
                  Пока пусто
                </div>
              )}
              <Button
                fluid
                icon="play"
                disabled={!addedReagents.length}
                onClick={startReagentSimulation}
              >
                Старт
              </Button>
              {particles.length > 0 && (
                <div
                  style={{
                    textAlign: 'center',
                    color: '#42e58d',
                    marginTop: '3px',
                  }}
                >
                  Частиц: {particles.length}
                </div>
              )}
            </div>
          </div>

          <div
            style={{
              position: 'absolute',
              right: '10px',
              bottom: '10px',
              width: '190px',
              padding: '10px',
              color: '#e5eaf2',
              backgroundColor: 'rgba(8, 15, 27, 0.94)',
              border: '1px solid #51627a',
              borderRadius: '4px',
              pointerEvents: 'none',
            }}
          >
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
              </>
            ) : (
              <div style={{ fontSize: '11px', lineHeight: '16px' }}>
                Нажмите на клетку, чтобы посмотреть её характеристики
              </div>
            )}
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
