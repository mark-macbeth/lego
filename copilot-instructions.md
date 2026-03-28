---
description: "Workspace instructions for LEGO art repository - streamline publishing process for Digital LEGO creations"
---

# Mark's MOCs: LEGO Art Repository Instructions

This repository showcases digital LEGO creations built in BrickLink Studio. It's a curated art portfolio organized by mission phases, with supporting models and documentation.

## Repository Structure

**Vignettes** (Primary focus):
- **Erimos System Phase I**: RP-01 through RP-05, plus PS-B, RP-06-pre, and RP-06 (Deep Space Explorer missions, Lagrange Point Refueling Station, Phoenix Station)
- **Erimos System Phase II**: RP-07-pre, RP-07, RP-08-pre, RP-08 (Erimos IV Missions), ES-09 (Astreus Station)
- Each vignette has sub-sections: walkthrough, builds, planetary views, renders, hover tractors, etc.

**Models** (Supporting crafts):
- `space-transporter.md`: Base shuttle with variants (A, B, C, C+-DSE)
- `space-transporter-extender.md`: Range-extended variants (ER, LR-DSE)
- `drone-transporter.md`: Autonomous cargo delivery

**Renders** (Legacy): Sequential render series 01-landing-pad through 19-catch-a-ride (archived work)

**Documentation**: README.md (index), license, attribution, FAQ, 28192.md, copilot-instructions.md

**Assets**: Images in `/images/`, utility scripts in `/bin/`

## Content Guidelines

When updating or creating content:

- **Vignettes**: Maintain mission structure and phase organization; each sub-section should have descriptive README and supporting images
- **Models**: Document variants, specifications, piece counts, and dimensional metrics
- **Cross-references**: Link vignettes to related models (e.g., RP-01 uses Space Transporter C+-DSE)
- **Artistic intent**: Preserve the narrative flow of missions and stations
- **Consistency**: Use standardized formatting for specifications, renders, and navigation links

## Publishing Workflow

When assisting with updates:

1. **Vignette additions**: Create new phase/mission folder with README, organize sub-sections, add navigation links
2. **Model updates**: Document variants, update specifications table, maintain .io file links
3. **Image management**: Organize assets in `/renders/` and vignette subdirectories; maintain naming conventions
4. **Root documentation**: Update README.md index when adding new vignettes or missions
5. **Cross-linking**: Ensure vignette README files link back to root and forward to sub-sections

## Key Principles

- Treat as documentation/art portfolio, not code
- Use semantic search to find related content across vignettes and phases
- Batch updates are useful for consistent formatting or linking
- Model files (.io) require minimal modification; focus on documentation
- Preserve all mission context and narrative structure