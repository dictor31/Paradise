import { Box } from './Box';

type Props = {
  title: string;
  subtitle: string;
};

export const BotHeader = ({ title, subtitle }: Props) => {
  return (
    <Box className="header">
      <Box className="title">
        {title}
      </Box>

      <Box className="sub">
        {subtitle}
      </Box>
    </Box>
  );
};
