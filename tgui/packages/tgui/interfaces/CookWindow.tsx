import { useState } from 'react';
import { LabeledList, Section, Tabs } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Recipe = {
  name: string;
  items: string[];
  reagents: string[];
};

type CookData = {
  Grill: Recipe[];
  Microwave: Recipe[];
  Oven: Recipe[];
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
            <Section key={index} title={recipe.name}>
              <LabeledList>
                <LabeledList.Item label="Ингредиенты">
                  <ul>
                    {recipe.items.map((item, itemIndex) => (
                      <li key={itemIndex}>{item}</li>
                    ))}
                  </ul>
                </LabeledList.Item>

                {recipe.reagents.length > 0 && (
                  <LabeledList.Item label="Реагенты">
                    <ul>
                      {recipe.reagents.map((reagent, reagentIndex) => (
                        <li key={reagentIndex}>{reagent}</li>
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
