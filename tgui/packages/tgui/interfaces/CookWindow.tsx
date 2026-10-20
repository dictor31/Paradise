
import { useState } from 'react';
import { LabeledList, Section, Tabs } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Ingredient = {
  name: string;
  amount: number;
};

type Recipe = {
  name: string;
  items: Ingredient[];
  reagents: Ingredient[];
};

type CookData = {
  Grill: Recipe[];
  Microwave: Recipe[];
  Oven: Recipe[];
  Candy: Recipe[];
};

const categories = [
  { key: 'Grill', label: 'Гриль' },
  { key: 'Microwave', label: 'Микроволновка' },
  { key: 'Oven', label: 'Печь' },
  { key: 'Candy', label: 'Сладости' },
] as const;

export const CookWindow = (props: unknown) => {
  const { data } = useBackend<CookData>();

  const [selectedCategory, setSelectedCategory] =
    useState<(typeof categories)[number]['key']>('Grill');

  const recipes = data[selectedCategory] ?? [];

  return (
    <Window width={600} height={500} title="Рецепты персонажа">
      <Window.Content scrollable>
        <Tabs>
          {categories.map(({ key, label }) => (
            <Tabs.Tab
              key={key}
              selected={selectedCategory === key}
              onClick={() => setSelectedCategory(key)}
            >
              {label}
            </Tabs.Tab>
          ))}
        </Tabs>

        <Section title="Рецепты">
          {recipes.map((recipe, index) => (
            <Section
              key={`${recipe.name}-${index}`}
              title={recipe.name}
            >

<LabeledList>
  {recipe.items.length > 0 && (
    <LabeledList.Item label="Ингредиенты">
      <ul>
        {recipe.items.map((item, itemIndex) => (
          <li key={`${item.name}-${itemIndex}`}>
            {item.name} — {item.amount} шт.
          </li>
        ))}
      </ul>
    </LabeledList.Item>
  )}

  {recipe.reagents.length > 0 && (
    <LabeledList.Item label="Реагенты">
      <ul>
        {recipe.reagents.map((reagent, reagentIndex) => (
          <li key={`${reagent.name}-${reagentIndex}`}>
            {reagent.name} — {reagent.amount} ед.
          </li>
        ))}
      </ul>
    </LabeledList.Item>
  )}
</LabeledList>

            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
