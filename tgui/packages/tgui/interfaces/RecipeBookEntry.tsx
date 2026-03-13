import { memo } from 'react';
import { Box, Section } from 'tgui-core/components';

type Props = {
  html: string;
};

export const RecipeBookEntry = memo((props: Props) => {
  const { html } = props;

  if (!html) {
    return (
      <Section fill scrollable>
        <Box color="label" textAlign="center" mt={4}>
          Select an entry from the list to view details.
        </Box>
      </Section>
    );
  }

  return (
    <Section fill scrollable>
      <style>
        {`.recipe-detail .icon { margin-right: 8px; vertical-align: middle; }`}
      </style>
      <Box
        className="recipe-detail"
        dangerouslySetInnerHTML={{ __html: html }}
        style={{
          textAlign: 'left',
        }}
      />
    </Section>
  );
});
