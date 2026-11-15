import { useEffect, useState } from 'react';
import { Window } from '../layouts';

type VirusCell = {
  id: number;
  x: number;
  y: number;
  vx: number;
  vy: number;
  age: number;
  size: number;
};

const AREA_WIDTH = 800;
const AREA_HEIGHT = 460;
const MAX_CELLS = 28;
const DIVISION_TICKS = 90;

const createInitialCells = (): VirusCell[] => {
  const positions = [
    [110, 90],
    [285, 185],
    [480, 95],
    [680, 160],
    [185, 355],
    [535, 345],
  ];

  return positions.map(([x, y], index) => ({
    id: index + 1,
    x,
    y,
    vx: (Math.random() - 0.5) * 2.2,
    vy: (Math.random() - 0.5) * 2.2,
    age: 0,
    size: 17 + Math.round(Math.random() * 3),
  }));
};

const advanceCells = (cells: VirusCell[]): VirusCell[] => {
  const next = cells.map((cell) => {
    let x = cell.x + cell.vx;
    let y = cell.y + cell.vy;
    let vx = cell.vx;
    let vy = cell.vy;

    if (x < cell.size + 4 || x > AREA_WIDTH - cell.size - 4) {
      vx *= -1;
      x = Math.max(cell.size + 4, Math.min(AREA_WIDTH - cell.size - 4, x));
    }
    if (y < cell.size + 4 || y > AREA_HEIGHT - cell.size - 4) {
      vy *= -1;
      y = Math.max(cell.size + 4, Math.min(AREA_HEIGHT - cell.size - 4, y));
    }

    return { ...cell, x, y, vx, vy, age: cell.age + 1 };
  });

  let nextId = next.reduce((highest, cell) => Math.max(highest, cell.id), 0) + 1;

  for (let index = 0; index < next.length && next.length < MAX_CELLS; index++) {
    const cell = next[index];
    if (cell.age < DIVISION_TICKS) {
      continue;
    }

    const speed = Math.hypot(cell.vx, cell.vy) || 1;
    const offsetX = (-cell.vy / speed) * cell.size * 0.55;
    const offsetY = (cell.vx / speed) * cell.size * 0.55;

    next[index] = {
      ...cell,
      x: cell.x - offsetX,
      y: cell.y - offsetY,
      vx: cell.vx * 0.9,
      vy: cell.vy * 0.9,
      age: 0,
    };

    next.push({
      ...cell,
      id: nextId++,
      x: cell.x + offsetX,
      y: cell.y + offsetY,
      vx: (cell.vy / speed) * speed * 0.9,
      vy: (-cell.vx / speed) * speed * 0.9,
      age: 0,
    });
  }

  return next;
};

export const VirusMicroscope = (_props: unknown) => {
  const [cells, setCells] = useState<VirusCell[]>(createInitialCells);

  useEffect(() => {
    const interval = window.setInterval(() => {
      setCells(advanceCells);
    }, 80);

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
            width: '100%',
            height: '460px',
            overflow: 'hidden',
            backgroundColor: '#101a2a',
            border: '1px solid #293b54',
          }}
        >
          <svg
            viewBox={`0 0 ${AREA_WIDTH} ${AREA_HEIGHT}`}
            width="100%"
            height="100%"
            style={{ display: 'block', imageRendering: 'pixelated' }}
            aria-label="Движущиеся и делящиеся красные клетки"
          >
            <rect
              x="0"
              y="0"
              width={AREA_WIDTH}
              height={AREA_HEIGHT}
              fill="#101a2a"
            />
            {cells.map((cell) => (
              <g
                key={cell.id}
                transform={`translate(${cell.x} ${cell.y}) scale(${cell.size / 20})`}
              >
                {/* Outer membrane: a dark, one-pixel-thick stepped ring. */}
                <path
                  d="M -8 -20 H 8 V -16 H 16 V -8 H 20 V 8 H 16 V 16 H 8 V 20 H -8 V 16 H -16 V 8 H -20 V -8 H -16 V -16 H -8 Z"
                  fill="#741b2c"
                />
                {/* Inner cell layer: a flat, bright red fill. */}
                <path
                  d="M -8 -16 H 8 V -12 H 12 V -8 H 16 V 8 H 12 V 12 H 8 V 16 H -8 V 12 H -12 V 8 H -16 V -8 H -12 V -12 H -8 Z"
                  fill="#df4b5b"
                />
                {/* Nucleus: a small, clearly separated dark center. */}
                <path
                  d="M -4 -8 H 4 V -4 H 8 V 4 H 4 V 8 H -4 V 4 H -8 V -4 H -4 Z"
                  fill="#641629"
                />
                <rect x="-4" y="-4" width="4" height="4" fill="#a92e43" />
              </g>
            ))}
          </svg>
        </div>
      </Window.Content>
    </Window>
  );
};
