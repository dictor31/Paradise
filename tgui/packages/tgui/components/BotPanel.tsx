import { Box } from './Box';

type Props = {
  title: string;
  children: React.ReactNode;
};

export const BotPanel = ({ title, children }: Props) => {
  return (
    <Box className="panel">

      <Box className="panelTitle">
        {title}
      </Box>

      {children}

    </Box>
  );
};
