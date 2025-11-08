# Changelog 

All notable changes to Lookout will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-08

### Added
- **SQLite Support**: Full compatibility with SQLite databases alongside existing PostgreSQL support
- **Database Adapter Layer**: Automatic detection and SQL generation for PostgreSQL vs SQLite
- **Sparkline Charts**: Mini trend charts in stat tiles for visual at-a-glance insights
- **Auto-Property Selection**: Properties tab now defaults to showing 'url' property automatically
- **Improved Seed Data**: Enhanced test data generator with realistic global traffic patterns
- **Rails 8 Compatibility**: Full support for Rails 8.x with proper Action Mailer configuration

### Fixed
- **Conversion Funnel Ordering**: Funnels now respect goal order as defined in configuration
- **Funnel Chart Visualization**: Removed confusing stacked datasets, now shows clean descending bars
- **Funnel Navigation**: Dropdown properly highlights when any funnel is selected
- **Properties UX**: No longer shows empty state - immediately loads first property
- **Chart.js Loading**: Sparklines use Stimulus controllers for reliable Chart.js loading
- **JSON Query Methods**: Database-agnostic JSON extraction for properties across PG & SQLite
- **Duration Formatting**: Fixed modulo calculation (4m 25s not 4M 252S)
- **Percentage Display**: Proper rounding to 2 decimals (10.81% not 10.810%)

### Changed
- **Rebrand**: Ahoy Captain → Lookout (fork with continued maintenance)
- **Repository**: Now at https://github.com/RubyOnVibes/lookout
- **Author**: Maintained by nativestranger / RubyOnVibes
- **Version**: Starting at 0.1.0 to signal new governance
- **Pagy**: Locked to v9.x for stability (v43 has breaking changes)
- **Chart Dependencies**: Moved from prebundled to CDN via importmap (lighter repo)
- **Module Name**: `AhoyCaptain` → `Lookout` throughout codebase
- **Routes**: All paths updated (`ahoy_captain/*` → `lookout/*`)
- **Assets**: All JavaScript/CSS paths updated for new namespace

### Removed
- **Tech Debt**: Removed 200KB+ prebundled chartjs-chart-geo (now uses CDN)
- **Unused Code**: Removed unused map_controller.js (inline script approach works better)

### Technical Details
- 389 files updated in comprehensive rebrand
- Zero remaining references to old gem name
- All tests passing (7 examples, 0 failures)
- Gem size: 221KB
- Supports: Ruby 3.0+, Rails 6.0-8.x

### Migration from Ahoy Captain
If migrating from ahoy_captain to lookout:

1. Update Gemfile: `gem "lookout"` (instead of ahoy_captain)
2. Update config: `Lookout.configure` (instead of AhoyCaptain)
3. Update routes: `mount Lookout::Engine` (instead of AhoyCaptain::Engine)
4. Update importmap (if customized): Change ahoy_captain paths to lookout
5. Run: `bundle install`

All data structures remain compatible - no database changes needed!

---

## Credits

Lookout is a fork of [Ahoy Captain](https://github.com/joshmn/ahoy_captain) by Josh Brody (joshmn).

Original concept and implementation by Josh Brody. SQLite support, bug fixes, and continued maintenance by nativestranger / RubyOnVibes.

## License

MIT License - See MIT-LICENSE file
