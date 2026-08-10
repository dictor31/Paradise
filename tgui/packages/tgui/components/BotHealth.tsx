import { Box } from './Box';

type Props = {
  health: number;
  maxHealth: number;
};

export const BotHealth = ({
  health,
  maxHealth,
}: Props) => {
  const healthPercent =
    maxHealth > 0
      ? Math.max(
          0,
          Math.min(
            100,
            (health / maxHealth) * 100,
          ),
        )
      : 0;

  return (
    <Box className="healthBlock">

      <Box className="healthTitle">
        ЦЕЛОСТНОСТЬ КОРПУСА
      </Box>

      <Box className="healthBar">

        <Box
          className={
            healthPercent > 60
              ? 'healthFill healthy'
              : healthPercent > 30
                ? 'healthFill damaged'
                : 'healthFill critical'
          }
          style={{
            width: `${healthPercent}%`,
          }}
        />

      </Box>

    </Box>
  );
};
