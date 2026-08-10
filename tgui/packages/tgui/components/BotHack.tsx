import { Button, Box } from '../components';

type Props = {
  emagged: boolean;
  disabled?: boolean;
  onClick: () => void;
};

export const BotHack = ({
  emagged,
  disabled = false,
  onClick,
}: Props) => {
  return (
    <Box className="danger">

      <Box className="dangerTitle">
        КРИТИЧЕСКИЙ ДОСТУП
      </Box>

      <Button
        fluid
        color="bad"
        icon="terminal"
        disabled={disabled}
        onClick={onClick}
      >
        {emagged
          ? 'Восстановить защиту'
          : 'Взломать систему'}
      </Button>

    </Box>
  );
};
