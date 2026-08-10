import { Box } from './Box';

type Props = {
  on: boolean;
  onToggle: () => void;
};

export const BotPower = ({ on, onToggle }: Props) => {
  return (
    <Box className="systemCore">

      <Box
        className={
          on
            ? 'coreStatus online'
            : 'coreStatus offline'
        }
      >
        {on
          ? 'СИСТЕМА АКТИВНА'
          : 'СИСТЕМА ОТКЛЮЧЕНА'}
      </Box>

      <Box
        className={
          on
            ? 'powerToggle active'
            : 'powerToggle'
        }
        onClick={onToggle}
      >

        <Box className="toggleLabel">
          ПИТАНИЕ
        </Box>

        <Box className="toggleBody">

          <Box
            className={
              on
                ? 'toggleSwitch switchOn'
                : 'toggleSwitch'
            }
          />

        </Box>

      </Box>

    </Box>
  );
};
