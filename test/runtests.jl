using Test
using STARSDataFusion

using Rasters

const TEST_TIF = joinpath(@__DIR__, "test.tif")
const OUTPUT_TIF = joinpath(@__DIR__, "test_output.tif")

@testset "STARSDataFusion basic loading" begin
    @test true  # Replace with real tests
end


@testset "Rasters read GeoTIFF" begin
    raster = Raster(TEST_TIF)
    @test !isnothing(raster)
    @test size(raster) != ()
end

@testset "Rasters write GeoTIFF" begin
    raster = Raster(TEST_TIF)
    write(OUTPUT_TIF, raster; force=true)
    @test isfile(OUTPUT_TIF)
    # Optionally, read back and check equality of dimensions
    written = Raster(OUTPUT_TIF)
    @test size(written) == size(raster)
end
