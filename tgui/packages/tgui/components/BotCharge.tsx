import { Box } from './Box';

type Props = {
  charge: number;
};

export const BotCharge = ({ charge }: Props) => {
  const percent = Math.max(0, Math.min(100, charge));

  return (
    <Box className="chargeBlock">

      <Box className="chargeTitle">
        ЗАРЯД БАТАРЕИ
      </Box>

      <Box className="chargeBar">
        <Box
          className={
            percent > 60
              ? 'chargeFill good'
              : percent > 30
                ? 'chargeFill warn'
                : 'chargeFill bad'
          }
          style={{
            width: `${percent}%`,
          }}
        />
      </Box>

      <Box className="chargeValue">
        {percent}%
      </Box>

    </Box>
  );
};
