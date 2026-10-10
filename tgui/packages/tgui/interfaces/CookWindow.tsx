import { LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Recipe = {
  name: string;
  result: string;
  items: string[];
  reagents: string[];
};

type CookData = {
  recipes: Recipe[];
};

export const CookWindow = (props: unknown) => {
  const { data } = useBackend<CookData>();

  return (
    <Window width={600} height={500} title="Рецепты персонажа">
      <Window.Content scrollable>
        <Section title="Рецепты">
  {data.recipes.map((recipe, index) => (
    <Section key={index} title={recipe.name}>
      <LabeledList>
        <LabeledList.Item label="Ингредиенты">
          {recipe.items.join(', ')}
        </LabeledList.Item>
        <LabeledList.Item label="Реагенты">
          {recipe.reagents.join(', ')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  ))}
</Section>
      </Window.Content>
    </Window>
  );
};
