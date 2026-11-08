// Adapted from Azure-Peak/Azure-Peak at b909200befe0745fc7194bc9f5704ace780d54f1 (AGPL-3.0).
import { memo } from 'react';
import { Box, Section } from 'tgui-core/components';

const DETAIL_STYLES = `
      .recipe-detail .icon { margin-right: 8px; vertical-align: middle; }
      .recipe-detail h2, .recipe-detail h3 { border-bottom: 1px solid currentColor; padding-bottom: 4px; }
      .recipe-detail ul, .recipe-detail ol { padding-left: 20px; }
      .recipe-detail li { margin: 4px 0; }
`;

export const RecipeBookEntry = memo(({ html }: { html: string }) => (
  <Section fill scrollable>
    <style>{DETAIL_STYLES}</style>
    {html ? (
      <Box
        className="recipe-detail"
        style={{ textAlign: 'left', padding: '4px 8px 24px' }}
        dangerouslySetInnerHTML={{ __html: html }}
      />
    ) : (
      <Box color="label" textAlign="center" mt={4}>
        Select an entry from the list to view details.
      </Box>
    )}
  </Section>
));
