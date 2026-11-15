import { useEffect, useState } from 'react';
import { Window } from '../layouts';

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
const MAX_LIFETIME = 1050;
const STRENGTH_DECAY_INTERVAL = 120;

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

const advanceCells = (cells: VirusCell[]): VirusCell[] => {
  const next: VirusCell[] = [];
  const offspring: VirusCell[] = [];
  let nextId = cells.reduce((highest, cell) => Math.max(highest, cell.id), 0) + 1;

  for (const cell of cells) {
    const moved = cell.stage === 'dying' ? cell : moveCell(cell);
    let updated = moved.with({ age: cell.age + 1 });

    if (
      updated.stage !== 'dying' &&
      updated.age > 0 &&
      updated.age % STRENGTH_DECAY_INTERVAL === 0
    ) {
      updated = updated.with({
        outerStrength: Math.max(0, updated.outerStrength - 2),
        innerStrength: Math.max(0, updated.innerStrength - 1),
        nucleusStrength: Math.max(0, updated.nucleusStrength - 1),
      });
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

  let dyingIndex = next.findIndex((cell) => cell.stage === 'dying');
  if (dyingIndex === -1 && next.length > MIN_CELLS) {
    const oldestCell = next
      .map((cell, index) => ({ cell, index }))
      .filter(
        ({ cell }) =>
          cell.stage === 'normal' && cell.age >= MAX_LIFETIME,
      )
      .sort((a, b) => b.cell.age - a.cell.age)[0];

    if (oldestCell) {
      dyingIndex = oldestCell.index;
      next[dyingIndex] = oldestCell.cell.with({
        stage: 'dying',
        stageTicks: 0,
      });
    }
  }

  const divisionInProgress = next.some(
    (cell) =>
      cell.stage === 'growing' ||
      cell.stage === 'stretching' ||
      cell.stage === 'splitting',
  );

  if (
    dyingIndex === -1 &&
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
      fill="#741b2c"
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
  const [cells, setCells] = useState<VirusCell[]>(createInitialCells);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const selectedCell = cells.find((cell) => cell.id === selectedId);

  useEffect(() => {
    const interval = window.setInterval(() => {
      setCells(advanceCells);
    }, TICK_INTERVAL);

    return () => window.clearInterval(interval);
  }, []);

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
