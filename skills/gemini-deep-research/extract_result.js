// Script à injecter dans gemini.google.com pour extraire le rapport Deep Research
// Retourne { success, markdown, html, word_count, links }

(() => {
  // Trouver le dernier conteneur de contenu de recherche
  const selectors = [
    '[class*="research-report"]',
    '[class*="deep-research"]',
    '[class*="research"][class*="content"]',
    'message-content',
    '[class*="model-response"]',
    '[data-test-id*="response"]'
  ];

  let container = null;
  for (const sel of selectors) {
    const els = document.querySelectorAll(sel);
    if (els.length > 0) {
      container = els[els.length - 1]; // le plus récent
      break;
    }
  }

  if (!container) {
    return { success: false, error: 'Aucun conteneur de rapport trouvé' };
  }

  const text = container.innerText || '';
  const html = container.innerHTML || '';

  // Conversion HTML → Markdown basique (fallback si Turndown absent)
  function htmlToMd(el) {
    let md = '';
    for (const node of el.childNodes) {
      if (node.nodeType === 3) {
        // Text node
        md += node.textContent;
      } else if (node.nodeType === 1) {
        const tag = node.tagName.toLowerCase();
        const inner = htmlToMd(node);
        switch (tag) {
          case 'h1': md += `\n# ${inner}\n\n`; break;
          case 'h2': md += `\n## ${inner}\n\n`; break;
          case 'h3': md += `\n### ${inner}\n\n`; break;
          case 'h4': md += `\n#### ${inner}\n\n`; break;
          case 'p': md += `\n${inner}\n\n`; break;
          case 'strong': case 'b': md += `**${inner}**`; break;
          case 'em': case 'i': md += `*${inner}*`; break;
          case 'code': md += `\`${inner}\``; break;
          case 'pre': md += `\n\`\`\`\n${inner}\n\`\`\`\n`; break;
          case 'ul': md += `\n${inner}\n`; break;
          case 'ol': md += `\n${inner}\n`; break;
          case 'li': md += `- ${inner}\n`; break;
          case 'a': {
            const href = node.getAttribute('href') || '#';
            md += `[${inner}](${href})`;
            break;
          }
          case 'br': md += '\n'; break;
          case 'table': md += `\n${inner}\n`; break;
          case 'tr': md += `${inner}\n`; break;
          case 'th': case 'td': md += `| ${inner} `; break;
          case 'blockquote': md += `\n> ${inner}\n`; break;
          default: md += inner;
        }
      }
    }
    return md;
  }

  const markdown = htmlToMd(container).replace(/\n{3,}/g, '\n\n').trim();

  // Extraire les liens/sources
  const links = [...container.querySelectorAll('a[href]')]
    .map(a => ({ text: a.innerText.trim(), url: a.href }))
    .filter(l => l.url && l.url.startsWith('http'));

  const wordCount = text.split(/\s+/).filter(Boolean).length;

  return {
    success: true,
    markdown,
    html,
    text,
    word_count: wordCount,
    links,
    link_count: links.length
  };
})();
