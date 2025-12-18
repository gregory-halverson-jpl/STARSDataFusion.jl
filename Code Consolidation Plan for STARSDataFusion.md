# STARSDataFusion.jl Consolidation Action Plan

**Repository:** STARS-Data-Fusion/STARSDataFusion.jl  
**Date:** December 18, 2025  
**Status:** Ready for Implementation  

---

## Overview

This action plan details the changes needed in **STARSDataFusion.jl** to consolidate shared utility code from HyperSTARS.jl. After completion, STARSDataFusion will provide enhanced utility functions that both packages can use.

### Goals for This Repository

1. ✅ Replace GP_utils.jl with more complete version from HyperSTARS
2. ✅ Merge resampling_utils.jl to include spectral functions from HyperSTARS
3. ✅ Maintain 100% backward compatibility - no breaking changes
4. ✅ Add exports for new utility functions
5. ✅ Update tests and documentation

### What Stays the Same

- All existing exports remain unchanged
- All existing function signatures preserved
- All submodules (BBoxes, HLS, VNP43, sentinel_tiles) unchanged
- All spatial fusion algorithms unchanged
- Production code continues to work without modifications

---

## Action Items

### Phase 1: Update Utility Files (Week 1-2)

#### Task 1.1: Replace GP_utils.jl ⚠️ CRITICAL

**File:** `src/GP_utils.jl`

**Action:** Replace current file (79 lines) with HyperSTARS version (163 lines)

**Current file has:**
- `exp_cor`, `mat32_cor`, `mat52_cor`
- `exp_corD`, `mat32_corD`, `mat52_corD`
- `matern_cor`, `matern_cor_nonsym`, `matern_cor_fast`
- `kernel_matrix`, `state_cov`

**New file adds:**
- `build_gpcov` (2 methods)
- `mat32_1D`, `mat32_cor2`, `mat32_cor3`
- More robust implementations (tolerance parameter, median calculation)

**Steps:**
1. ✅ Copy `HyperSTARS.jl/src/GP_utils.jl` → `STARSDataFusion.jl/src/GP_utils.jl`
2. ✅ Verify all existing function signatures match
3. ✅ Test that production code using `exp_cor` works unchanged
4. ✅ Add unit tests for new functions

**Verification:**
```julia
# Test existing functions still work
@test methods(exp_cor) == <existing methods>
@test exp_cor([0,0], [1,1], [1.0, 200.0, 1e-10, 1.5]) ≈ <expected>

# Test new functions
@test isa(build_gpcov(...), Matrix)
@test mat32_1D(...) ≈ <expected>
```

**Risk:** Medium - Function implementations differ slightly  
**Mitigation:** Extensive regression testing on production-like data

---

#### Task 1.2: Merge resampling_utils.jl

**File:** `src/resampling_utils.jl`

**Action:** Append HyperSTARS spectral functions to existing file

**Current file has (86 lines):**
- `gauss_weighted_obs_operator()`
- `unif_weighted_obs_operator()`
- `unif_weighted_obs_operator_centroid()` ⚠️ Used in production
- `uniform_obs_operator_indices()`

**Add from HyperSTARS:**
```julia
# Spectral response function convolution matrix
function rsr_conv_matrix(rsr::AbstractArray, wl_in, wl_out, sig)
    # ... implementation from HyperSTARS
end

function rsr_conv_matrix(rsr::Dict, wl_in, wl_out)
    # ... implementation from HyperSTARS
end
```

**Steps:**
1. ✅ Open `src/resampling_utils.jl`
2. ✅ Append the two `rsr_conv_matrix` functions from `HyperSTARS.jl/src/resampling_utils.jl`
3. ✅ Ensure no function name conflicts
4. ✅ Keep all existing functions unchanged

**Verification:**
```julia
# Verify existing functions unchanged
@test unif_weighted_obs_operator_centroid(...) ≈ <expected>
@test gauss_weighted_obs_operator(...) ≈ <expected>

# Test new spectral functions
@test isa(rsr_conv_matrix(rsr, wl_in, wl_out, sig), Matrix)
```

**Risk:** Low - additive changes only  
**Dependencies:** Requires `Interpolations.jl` (already in Project.toml)

---

#### Task 1.3: Verify spatial_utils_ll.jl (No Changes)

**File:** `src/spatial_utils_ll.jl`

**Action:** Verify file is identical to HyperSTARS version

**Steps:**
1. ✅ Run diff check:
   ```bash
   diff src/spatial_utils_ll.jl ../HyperSTARS.jl/src/spatial_utils_ll.jl
   ```
2. ✅ Should show: Files are identical (378 lines each)
3. ✅ No changes needed

**Verification:**
```julia
# Verify all functions still work
@test find_nearest_ij(...) == <expected>
@test get_centroid_origin_raster(...) == <expected>
@test cell_size(...) == <expected>
```

**Risk:** None - verification only

---

### Phase 2: Update Module Exports (Week 2)

#### Task 2.1: Add New Exports to Main Module

**File:** `src/STARSDataFusion.jl`

**Action:** Add exports for new functions from enhanced utilities

**Current exports (keep all):**
```julia
# Main fusion functions
export STARS_fusion
export coarse_fine_data_fusion
export coarse_fine_data_fusion_SS
export coarse_fine_scene_fusion_pmap
export coarse_fine_scene_fusion_inds_pmap
export coarse_fine_scene_fusion_cbias_pmap  # ← CRITICAL for production

# Parameter estimation
export MLE_estimation
export fast_var_est  # ← CRITICAL for production
export compute_n_eff  # ← CRITICAL for production

# Data structures
export DataFusionState
export STARSInstrumentData      # ← CRITICAL for production
export STARSInstrumentGeoData   # ← CRITICAL for production

# Utilities
export cell_size                 # ← CRITICAL for production
export get_centroid_origin_raster  # ← CRITICAL for production
export nanmean  # ← CRITICAL for production
export nanvar

# Covariance functions
export exp_cor      # ← CRITICAL for production
export mat32_cor
export mat52_cor
export state_cov

# Observation operators
export unif_weighted_obs_operator
export unif_weighted_obs_operator_centroid  # ← CRITICAL for production
```

**Add new exports:**
```julia
# New from enhanced GP_utils.jl
export build_gpcov
export mat32_1D
export mat32_cor2
export mat32_cor3

# New from enhanced resampling_utils.jl
export rsr_conv_matrix
```

**Steps:**
1. ✅ Open `src/STARSDataFusion.jl`
2. ✅ Add new export statements (grouped logically)
3. ✅ Verify no duplicate exports
4. ✅ Test that all exports resolve

**Verification:**
```julia
using STARSDataFusion

# Verify new exports available
@test isdefined(STARSDataFusion, :build_gpcov)
@test isdefined(STARSDataFusion, :mat32_1D)
@test isdefined(STARSDataFusion, :rsr_conv_matrix)

# Verify existing exports unchanged
@test isdefined(STARSDataFusion, :exp_cor)
@test isdefined(STARSDataFusion, :coarse_fine_scene_fusion_cbias_pmap)
```

**Risk:** Low - additive changes only

---

### Phase 3: Testing (Week 3)

#### Task 3.1: Update Unit Tests

**File:** `test/runtests.jl` (or create new test files)

**Action:** Add tests for enhanced utilities

**New test file:** `test/test_gp_utils.jl`
```julia
using Test
using STARSDataFusion

@testset "GP_utils - Existing functions" begin
    # Test existing functions maintain behavior
    @test exp_cor([0,0], [1,1], [1.0, 200.0, 1e-10, 1.5]) ≈ <baseline>
    @test mat32_cor([0,0], [1,1], [1.0, 200.0, 1e-10, 1.5]) ≈ <baseline>
    @test mat52_cor([0,0], [1,1], [1.0, 200.0, 1e-10, 1.5]) ≈ <baseline>
end

@testset "GP_utils - New functions" begin
    # Test new functions from HyperSTARS
    @test isa(build_gpcov(...), Matrix)
    @test mat32_1D(...) ≈ <expected>
    @test mat32_cor2(...) ≈ <expected>
    @test mat32_cor3(...) ≈ <expected>
end
```

**New test file:** `test/test_resampling_utils.jl`
```julia
using Test
using STARSDataFusion

@testset "resampling_utils - Existing functions" begin
    @test unif_weighted_obs_operator_centroid(...) ≈ <baseline>
    @test gauss_weighted_obs_operator(...) ≈ <baseline>
end

@testset "resampling_utils - New spectral functions" begin
    @test isa(rsr_conv_matrix(rsr, wl_in, wl_out, sig), Matrix)
    @test size(rsr_conv_matrix(...)) == <expected>
end
```

**Steps:**
1. ✅ Create regression baselines from current version
2. ✅ Add tests for new functions
3. ✅ Run full test suite
4. ✅ Verify all tests pass

**Verification:**
```bash
julia --project -e 'using Pkg; Pkg.test()'
```

**Risk:** Medium - need good baseline data  
**Mitigation:** Use production-like synthetic data

---

#### Task 3.2: Production Code Validation

**Action:** Test that production code runs unchanged

**Create:** `test/test_production_compatibility.jl`
```julia
using Test
using Distributed
using STARSDataFusion
using STARSDataFusion.BBoxes
using STARSDataFusion.sentinel_tiles
using STARSDataFusion.HLS
using STARSDataFusion.VNP43

@testset "Production compatibility" begin
    # Test all critical imports work
    @test isdefined(STARSDataFusion, :STARSInstrumentData)
    @test isdefined(STARSDataFusion, :STARSInstrumentGeoData)
    @test isdefined(STARSDataFusion, :coarse_fine_scene_fusion_cbias_pmap)
    @test isdefined(STARSDataFusion, :exp_cor)
    @test isdefined(STARSDataFusion, :unif_weighted_obs_operator_centroid)
    @test isdefined(STARSDataFusion, :compute_n_eff)
    @test isdefined(STARSDataFusion, :fast_var_est)
    @test isdefined(STARSDataFusion, :nanmean)
    @test isdefined(STARSDataFusion, :cell_size)
    @test isdefined(STARSDataFusion, :get_centroid_origin_raster)
    
    # Test submodules accessible
    @test isdefined(Main, :BBoxes)
    @test isdefined(Main, :sentinel_tiles)
    @test isdefined(Main, :HLS)
    @test isdefined(Main, :VNP43)
    
    # Test distributed pattern
    addprocs(2)
    @everywhere using STARSDataFusion
    @test remotecall_fetch(isdefined, 2, STARSDataFusion, :exp_cor)
    rmprocs(workers())
end
```

**Steps:**
1. ✅ Run production validation tests
2. ✅ Test distributed computing pattern
3. ✅ Verify function signatures match expectations
4. ✅ Test on minimal synthetic data

**Risk:** High - critical for production systems  
**Mitigation:** Comprehensive testing, can rollback if issues

---

### Phase 4: Documentation (Week 3-4)

#### Task 4.1: Update README

**File:** `README.md`

**Action:** Document enhanced utilities

**Add section:**
```markdown
## Enhanced Utilities (New)

STARSDataFusion now includes enhanced utility functions consolidated from HyperSTARS.jl:

### GP Utilities
- `build_gpcov()` - Build Gaussian process covariance matrices
- `mat32_1D()`, `mat32_cor2()`, `mat32_cor3()` - Additional Matérn correlation functions
- Enhanced `kernel_matrix()` with tolerance parameter
- Robust `state_cov()` with median calculation

### Spectral Resampling
- `rsr_conv_matrix()` - Spectral response function convolution for hyperspectral data

All existing functions remain unchanged and backward compatible.
```

**Steps:**
1. ✅ Update README.md
2. ✅ Add usage examples for new functions
3. ✅ Note backward compatibility

---

#### Task 4.2: Update Documentation

**Files:** `docs/src/*.md` (if using Documenter.jl)

**Action:** Document new functions in API reference

**Steps:**
1. ✅ Add docstrings to new functions
2. ✅ Update API reference
3. ✅ Add examples if needed

---

### Phase 5: Version Release (Week 4)

#### Task 5.1: Update Project.toml

**File:** `Project.toml`

**Action:** Bump version number

**Current:** `version = "0.X.Y"`  
**New:** `version = "0.(X+1).0"`

**Rationale:** Minor version bump (new features, no breaking changes)

**Steps:**
1. ✅ Update version in Project.toml
2. ✅ Update CHANGELOG.md
3. ✅ Tag release in git

---

#### Task 5.2: Create CHANGELOG Entry

**File:** `CHANGELOG.md`

**Add:**
```markdown
## [0.X+1.0] - 2025-XX-XX

### Added
- Enhanced GP utilities from HyperSTARS.jl consolidation
  - `build_gpcov()` for Gaussian process covariance matrices
  - `mat32_1D()`, `mat32_cor2()`, `mat32_cor3()` correlation functions
- Spectral resampling utilities
  - `rsr_conv_matrix()` for hyperspectral response functions
- More robust implementations with tolerance parameters

### Changed
- Internal improvements to `kernel_matrix()` and `state_cov()` for better numerical stability
- No breaking changes - all existing APIs preserved

### Notes
- This release consolidates shared utilities with HyperSTARS.jl
- HyperSTARS.jl will depend on STARSDataFusion.jl for these utilities
- 100% backward compatible with existing code
```

---

## Testing Checklist

Before release, verify:

- [ ] All existing tests pass
- [ ] New function tests pass
- [ ] Production compatibility tests pass
- [ ] Examples run successfully
- [ ] `@everywhere using STARSDataFusion` works
- [ ] Distributed computing tests pass
- [ ] No performance regression (±10%)
- [ ] Documentation builds without errors
- [ ] README updated
- [ ] CHANGELOG updated

---

## Rollback Plan

If issues discovered after release:

1. **Immediate:** Tag current state as `v0.X.Y-pre-consolidation`
2. **Revert:** `git revert <consolidation-commits>`
3. **Release:** Tag reverted version as `v0.X.Y+1`
4. **Communicate:** Notify users of temporary rollback
5. **Fix:** Address issues and re-release

**Files to restore if rollback needed:**
- `src/GP_utils.jl` (from git history)
- `src/resampling_utils.jl` (from git history)
- `src/STARSDataFusion.jl` exports

---

## Timeline

| Week | Tasks | Status |
|------|-------|--------|
| 1 | Task 1.1: Replace GP_utils.jl | ⬜ Not Started |
| 1 | Task 1.2: Merge resampling_utils.jl | ⬜ Not Started |
| 2 | Task 1.3: Verify spatial_utils_ll.jl | ⬜ Not Started |
| 2 | Task 2.1: Update exports | ⬜ Not Started |
| 3 | Task 3.1: Unit tests | ⬜ Not Started |
| 3 | Task 3.2: Production validation | ⬜ Not Started |
| 3-4 | Task 4.1-4.2: Documentation | ⬜ Not Started |
| 4 | Task 5.1-5.2: Release | ⬜ Not Started |

---

## Dependencies

**After completion:**
- HyperSTARS.jl will add STARSDataFusion as a dependency
- HyperSTARS.jl will remove duplicate utility files
- Both packages will use STARSDataFusion utilities

**No changes needed for:**
- Production code using STARSDataFusion
- Any downstream packages
- Examples or tutorials

---

## Questions or Issues?

**Contact:**
- GitHub Issues: https://github.com/STARS-Data-Fusion/STARSDataFusion.jl/issues
- Maintainer: [contact email]

**Reference:**
- Full consolidation proposal: `../HyperSTARS.jl/Code Consolidation Proposal.md`
- HyperSTARS action plan: `../HyperSTARS.jl/CONSOLIDATION_ACTION_PLAN.md`

---

**Last Updated:** December 18, 2025  
**Status:** Ready for Implementation  
**Estimated Completion:** 4 weeks
