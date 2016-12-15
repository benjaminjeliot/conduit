###############################################################################
# Copyright (c) 2014-2016, Lawrence Livermore National Security, LLC.
# 
# Produced at the Lawrence Livermore National Laboratory
# 
# LLNL-CODE-666778
# 
# All rights reserved.
# 
# This file is part of Conduit. 
# 
# For details, see: http://software.llnl.gov/conduit/.
# 
# Please also read conduit/LICENSE
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, 
#   this list of conditions and the disclaimer below.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the disclaimer (as noted below) in the
#   documentation and/or other materials provided with the distribution.
# 
# * Neither the name of the LLNS/LLNL nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL LAWRENCE LIVERMORE NATIONAL SECURITY,
# LLC, THE U.S. DEPARTMENT OF ENERGY OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
# DAMAGES  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
# 
###############################################################################

if(ENABLE_DOCS)

add_custom_target(docs)

if(DOXYGEN_FOUND)
    add_custom_target(doxygen_docs)
    add_dependencies(docs doxygen_docs)
else()
    message(STATUS "Warning: ENABLE_DOCS = ON, but Doxygen was not found.")
endif()


if(SPHINX_FOUND)
    add_custom_target(sphinx_docs)
    add_dependencies(docs sphinx_docs)
else()
    message(STATUS "Warning: ENABLE_DOCS = ON, but Sphinx was not found.")
endif()


##------------------------------------------------------------------------------
## - Macro for invoking doxygen to generate docs
##
## add_doxygen_target(doxygen_target_name)
##
##  Expects to find a Doxyfile.in in the directory the macro is called in. 
##  
##  This macro sets up the doxygen paths so that the doc builds happen 
##  out of source. For a make install, this will place the resulting docs in 
##  docs/doxygen/`doxygen_target_name`
##
##------------------------------------------------------------------------------
macro(add_doxygen_target doxygen_target_name)
    # add a target to generate API documentation with Doxygen
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
    add_custom_target(${doxygen_target_name}
                     ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     COMMENT "Generating API documentation with Doxygen" VERBATIM)

    add_dependencies(doxygen_docs ${doxygen_target_name})

    install(CODE "execute_process(COMMAND ${CMAKE_BUILD_TOOL} ${doxygen_target_name} WORKING_DIRECTORY \"${CMAKE_CURRENT_BINARY_DIR}\")")

    install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html" 
            DESTINATION docs/doxygen/${doxygen_target_name})

endmacro(add_doxygen_target)

##------------------------------------------------------------------------------
## - Macro for invoking sphinx to generate docs
##
## add_sphinx_target(sphinx_target_name)
##
##  Expects to find a config.py.in in the directory the macro is called in. 
##  
##  This macro sets up the sphinx paths so that the doc builds happen 
##  out of source. For a make install, this will place the resulting docs in 
##  docs/sphinx/`sphinx_target_name`
##
##------------------------------------------------------------------------------
macro(add_sphinx_target sphinx_target_name )
    MESSAGE(STATUS "Creating sphinx docs target ${sphinx_target_name}")
    # configured documentation tools and intermediate build results
    set(SPHINX_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/_build")

    # Sphinx cache with pickled ReST documents
    set(SPHINX_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_doctrees")

    # HTML output directory
    set(SPHINX_HTML_DIR "${CMAKE_CURRENT_BINARY_DIR}/html")

    # support both a cmake config-d sphinx input file (config.py.in)
    # and direct use of a config.py file.
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in")
        
        configure_file("${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in"
                       "${SPHINX_BUILD_DIR}/conf.py"
                       @ONLY)

        add_custom_target(${sphinx_target_name}
                          ${SPHINX_EXECUTABLE}
                          -q -b html
                          #-W disable warn on error for now, while our sphinx env is still in flux
                          -c "${SPHINX_BUILD_DIR}"
                          -d "${SPHINX_CACHE_DIR}"
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          "${SPHINX_HTML_DIR}"
                          COMMENT "Building HTML documentation with Sphinx"
                          DEPENDS ${deps})
    else()
        add_custom_target(${sphinx_target_name}
                          ${SPHINX_EXECUTABLE}
                          -q -b html
                          #-W disable warn on error for now, while our sphinx env is still in flux
                          -d "${SPHINX_CACHE_DIR}"
                          "${CMAKE_CURRENT_SOURCE_DIR}"
                          "${SPHINX_HTML_DIR}"
                          COMMENT "Building HTML documentation with Sphinx"
                          DEPENDS ${deps})
    endif()
    # hook our new target into the docs dependency chain
    add_dependencies(sphinx_docs ${sphinx_target_name})

    ######
    # This snippet makes sure if we do a make install w/o the optional "docs"
    # target built, it will be built during the install process.
    ######

    install(CODE "execute_process(COMMAND ${CMAKE_BUILD_TOOL} ${sphinx_target_name} WORKING_DIRECTORY \"${CMAKE_CURRENT_BINARY_DIR}\")")

    install(DIRECTORY "${SPHINX_HTML_DIR}" 
            DESTINATION "docs/sphinx/${sphinx_target_name}")
endmacro(add_sphinx_target)

endif(ENABLE_DOCS) 


