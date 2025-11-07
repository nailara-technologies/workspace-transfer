# Token Visualization Guide

**Interactive dashboard for analyzing token usage patterns**

The token visualization system provides an interactive, browser-based dashboard for analyzing token usage statistics, trends, and efficiency patterns across your Protocol-7 workspace sessions.

---

## Quick Start

```bash
# Generate and open visualization dashboard
bin/token-viz

# Generate to specific file
bin/token-viz --output /path/to/dashboard.html
```

The dashboard will automatically open in your browser (when available) and display:
- Timeline chart with moving averages
- Bar chart by task type
- Distribution pie chart
- Statistical analysis table
- Trend indicators

---

## Features

### 1. Timeline Visualization
- **Line chart** showing token usage over time
- **Moving average** (5-session window) to identify trends
- Interactive tooltips with exact values
- Chronological view of all sessions

### 2. Task Type Analysis
- **Bar chart** comparing average token usage per task type
- Color-coded for easy identification
- Helps identify which tasks consume most tokens

### 3. Distribution Pie Chart
- Shows **proportional token usage** by task type
- Identifies which tasks dominate your workflow
- Interactive legend

### 4. Statistical Table
- **Comprehensive statistics** per task type:
  - Session count
  - Total tokens used
  - Average tokens per session
  - Min-max range
  - Trend indicator (up/down/stable)

### 5. Protocol-7 Themed Design
- Dark gradient background matching Protocol-7 aesthetic
- Glow effects and animations
- High contrast for readability
- Responsive layout

---

## How It Works

### Data Source

The visualization reads from `.token-stats.log` which is populated by:

```bash
bin/track-tokens <task> <tokens>
```

**Log format:**
```
timestamp|task|tokens
2025-11-07T09:30:00Z|init|2400
2025-11-07T11:40:20Z|development|8900
```

### Generation Process

1. **Read** token data from `.token-stats.log`
2. **Convert** to JavaScript array
3. **Inject** into HTML template
4. **Generate** standalone HTML file
5. **Auto-open** in browser (when available)

### No Data Fallback

If no tracking data exists, the dashboard displays **sample data** to demonstrate functionality. This allows you to:
- Preview the visualization style
- Understand the interface
- See example patterns

---

## Command Reference

### bin/token-viz

```bash
bin/token-viz [--output FILE]
```

**Options:**
- `--output FILE` - Specify output HTML file path
  - Default: `visualizations/token-dashboard-current.html`

**Examples:**

```bash
# Basic usage (auto-opens in browser)
bin/token-viz

# Save to specific location
bin/token-viz --output /tmp/my-tokens.html

# Generate for sharing (stable filename)
bin/token-viz --output visualizations/token-report-2025-11.html
```

**Exit codes:**
- `0` - Success (visualization generated)

---

## Workflow Integration

### Recommended Pattern

```bash
# 1. Track tokens during work
bin/track-tokens init 2400
bin/track-tokens development 8500
bin/track-tokens testing 5200

# 2. Generate visualization periodically
bin/token-viz

# 3. Review for:
#    - Trend changes (efficiency improving/degrading?)
#    - Task distribution (spending time on right things?)
#    - Anomalies (unusual spikes?)

# 4. Adjust workflow based on insights
```

### Analysis Questions

Use the visualization to answer:

**Efficiency:**
- Are my token costs trending up or down?
- Which tasks show improvement over time?
- Are there anomalous sessions to investigate?

**Distribution:**
- Am I spending tokens proportionally to value?
- Is documentation too expensive?
- Are initialization costs optimized?

**Planning:**
- What's a realistic budget for next task?
- When should I hand over to fresh session?
- Which task types need optimization?

---

## Interpreting Trends

### Timeline Chart

**Moving Average (purple line):**
- **Trending down** ✅ - Efficiency improving
- **Trending up** ⚠️ - May indicate context degradation
- **Stable** ➡️ - Consistent efficiency

**Individual points (green line):**
- Variance is normal
- Look for patterns, not individual spikes

### Task Statistics Table

**Trend Indicators:**
- 📈 **Up** (red) - Token usage increasing (>15% change)
  - May indicate inefficiency creeping in
  - Review recent sessions for redundancy
- 📉 **Down** (green) - Token usage decreasing (>15% change)
  - Efficiency improvements working!
  - Document what changed
- ➡️ **Stable** (yellow) - Consistent usage (<15% change)
  - Predictable, reliable baseline

**Range (Min-Max):**
- Wide range → High variability (investigate why)
- Narrow range → Consistent (good for planning)

---

## Technical Details

### Dependencies

The dashboard uses **Chart.js 4.4.0** via CDN:
```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
```

**No local installation required** - works offline after first load (browser cache).

### File Structure

```
visualizations/
├── token-usage-dashboard.html      # Template (with placeholder)
└── token-dashboard-current.html    # Generated (with real data)
```

**Template placeholder:**
```javascript
const TOKEN_DATA = /*TOKEN_DATA_PLACEHOLDER*/[];
```

**After generation:**
```javascript
const TOKEN_DATA = [
  {timestamp: "2025-11-07T09:30:00Z", task: "init", tokens: 2400},
  {timestamp: "2025-11-07T11:40:20Z", task: "development", tokens: 8900}
];
```

### Browser Compatibility

Works in all modern browsers:
- Chrome/Edge (Chromium) ✅
- Firefox ✅
- Safari ✅
- Opera ✅

Requires JavaScript enabled.

---

## Customization

### Color Scheme

The dashboard uses Protocol-7 colors:
- `#00ff88` - Primary (green)
- `#ff00ff` - Secondary (magenta)
- `#00ccff` - Tertiary (cyan)
- `#ffaa00` - Accent (orange)

### Chart Configuration

Charts use the **Chart.js API** and can be customized by editing:
```
visualizations/token-usage-dashboard.html
```

See [Chart.js documentation](https://www.chartjs.org/docs/) for options.

---

## Comparison with Text Reports

### bin/token-report (text)

**Strengths:**
- ✅ Fast (no browser needed)
- ✅ Terminal-friendly
- ✅ Good for CI/automation
- ✅ Includes statistical details

**Limitations:**
- ❌ Text-only sparklines
- ❌ No interactive exploration
- ❌ Harder to spot visual patterns

### bin/token-viz (visual)

**Strengths:**
- ✅ Visual pattern recognition
- ✅ Interactive (zoom, hover)
- ✅ Multiple chart types
- ✅ Better for presentations

**Limitations:**
- ❌ Requires browser
- ❌ Not terminal-native
- ❌ Slower generation

**Recommendation:** Use both!
- `bin/token-report` for quick checks
- `bin/token-viz` for deep analysis

---

## Troubleshooting

### "No tracking data found"

**Cause:** `.token-stats.log` doesn't exist or is empty

**Solution:**
```bash
# Start tracking
bin/track-tokens init 2400

# Verify log created
cat .token-stats.log

# Regenerate visualization
bin/token-viz
```

### "Template not found"

**Cause:** `visualizations/token-usage-dashboard.html` missing

**Solution:**
```bash
# Verify template exists
ls -l visualizations/token-usage-dashboard.html

# If missing, restore from git
git checkout visualizations/token-usage-dashboard.html
```

### Dashboard won't open automatically

**Cause:** No browser auto-open support on platform

**Solution:**
```bash
# Generate dashboard
bin/token-viz

# Manual open - copy/paste the file:// path shown
# Or:
open visualizations/token-dashboard-current.html       # macOS
xdg-open visualizations/token-dashboard-current.html   # Linux
start visualizations/token-dashboard-current.html      # Windows
```

### Chart.js not loading

**Cause:** Network issue (CDN blocked) or offline

**Solution:**
- Check internet connection
- Wait for browser cache to populate
- Use text reports as fallback: `bin/token-report`

---

## Future Enhancements

Potential additions:
- **Export charts** as images (PNG/SVG)
- **Real-time updates** (auto-refresh when log changes)
- **Date range filtering** (view specific time periods)
- **Comparison mode** (compare two sessions)
- **Efficiency scoring** (compound metric)
- **Predictive analytics** (forecast future usage)
- **Anomaly highlighting** (auto-detect outliers)

---

## Examples

### Scenario 1: Detecting Inefficiency

```bash
# After several sessions
bin/token-viz
```

**Observation:** Timeline shows upward trend in "development" tasks
**Action:** Review recent development sessions for redundant file reads
**Result:** Identify duplicate exploration, optimize workflow

### Scenario 2: Planning Budget

```bash
# Before starting new feature
bin/token-viz
```

**Observation:** "development" tasks average 8,500 tokens
**Action:** Budget 10,000 tokens for new feature (safety margin)
**Result:** Realistic planning, avoid mid-session handovers

### Scenario 3: Identifying Strengths

```bash
# After optimization work
bin/token-viz
```

**Observation:** "init" task trend shows 📉 down (2400 → 2000)
**Action:** Document what changed, apply pattern to other tasks
**Result:** Compound efficiency improvement

---

## See Also

- **TOKEN_TRACKING_GUIDE.md** - Tracking and self-optimization system
- **bin/token-report** - Text-based analytics
- **bin/track-tokens** - Record token usage
- **bin/suggest-handover** - Session health monitoring

---

**Version:** 1.0
**Created:** 2025-11-07
**Status:** Active feature in workspace-transfer
