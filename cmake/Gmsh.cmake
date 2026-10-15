include(FetchContent)

set(AMGEM_GMSH_GIT_TAG "00eea3fa722e9bc985cfa83596e2e775b988a274"
    CACHE STRING "Gmsh commit or release tag")

# Scope Gmsh's generic option names to this dependency. Its older minimum
# CMake version otherwise resets policies that preserve these normal variables.
function(amgem_add_gmsh)
    set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
    set(CMAKE_POLICY_DEFAULT_CMP0126 NEW)
    set(DEFAULT OFF)
    set(ENABLE_BUILD_LIB ON)
    # Also override cached options that could pull shared third-party libraries
    # or unrelated application components into an existing build directory.
    foreach(feature IN ITEMS
        BUILD_SHARED BUILD_DYNAMIC BUILD_ANDROID BUILD_IOS
        BLAS_LAPACK FLTK GRAPHICS OPENMP OCC OCC_CAF OCC_TBB
        MPI CGNS MED MMG MESQUITE PETSC MUMPS SLEPC GETDP
        GEOMETRYCENTRAL POPPLER FFMPEG TCMALLOC SYSTEM_CONTRIB
        TESTS PRIVATE_API WRAP_JAVA WRAP_PYTHON)
        set(ENABLE_${feature} OFF)
    endforeach()
    set(ENABLE_MESH ON)
    set(ENABLE_PARSER ON)
    set(ENABLE_POST ON)
    set(ENABLE_EIGEN ON)
    # Reparametrizing imported discrete surfaces (mesh.createGeometry) solves
    # linear systems. Bundled GMM provides sparse solves without external libs.
    set(ENABLE_SOLVER ON)
    set(ENABLE_GMM ON)
    # This revision includes tiny_obj_loader.h unconditionally in OBJ I/O.
    # The bundled implementation adds no external library dependency.
    set(ENABLE_TINYOBJLOADER ON)
    # Gmsh has no documentation switch. Suppress its optional documentation
    # tools so it does not create a "doc" target that collides with segyio's.
    set(MAKEINFO "")
    set(TEXI2PDF "")

    FetchContent_Declare(gmsh
        GIT_REPOSITORY https://gitlab.onelab.info/gmsh/gmsh.git
        GIT_TAG "${AMGEM_GMSH_GIT_TAG}"
        GIT_SUBMODULES ""
        EXCLUDE_FROM_ALL)

    FetchContent_MakeAvailable(gmsh)

    add_library(amgem_gmsh INTERFACE)
    target_link_libraries(amgem_gmsh INTERFACE lib ${GMSH_EXTERNAL_LIBRARIES})
endfunction()

amgem_add_gmsh()
