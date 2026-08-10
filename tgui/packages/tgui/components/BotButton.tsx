import { Box } from './Box';

type Props = {
  checked: boolean;
  disabled?: boolean;
  onClick: () => void;
  children: React.ReactNode;
  className?: string;
};

export const BotButton = ({
  checked,
  disabled = false,
  onClick,
  children,
  className = '',
}: Props) => {
  const stateClass = disabled
    ? 'disabled'
    : checked
      ? 'checked'
      : '';

  return (
    <Box
      className={`botButton ${stateClass} ${className}`}
      onClick={() => {
        if (!disabled) {
          onClick();
        }
      }}
    >
      <Box className="botButtonIndicator">
        <Box className="botButtonIndicatorCore" />
      </Box>

      <Box className="botButtonText">
        {children}
      </Box>

      <Box className="botButtonState">
        {disabled
          ? 'НЕДОСТУПНО'
          : checked
            ? 'ВКЛ'
            : 'ВЫКЛ'}
      </Box>
    </Box>
  );
};
