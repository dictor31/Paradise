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
                <path
                  d="M -7 -20 H 7 V -16 H 15 V -8 H 19 V 8 H 15 V 16 H 7 V 20 H -7 V 16 H -15 V 8 H -19 V -8 H -15 V -16 H -7 Z"
                  fill="#a92339"
                  stroke="#641829"
                  strokeWidth="3"
                />
                <path
                  d="M -6 -14 H 6 V -10 H 11 V 6 H 7 V 11 H -6 V 7 H -11 V -7 H -6 Z"
                  fill="#e74459"
                />
                <rect x="-5" y="-5" width="10" height="10" fill="#9d2035" />
                <rect x="-10" y="-10" width="4" height="4" fill="#ff9aa5" />
                <rect x="7" y="6" width="4" height="4" fill="#ff8291" />
              </g>
            ))}
          </svg>
        </div>
      </Window.Content>
    </Window>
  );
};
