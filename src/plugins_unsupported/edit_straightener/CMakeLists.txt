# Copyright 2019-2020, Collabora, Ltd.
# SPDX-License-Identifier: BSL-1.0

### Generated file! Edit the templates in src/templates,
### specifically src/templates/CMakeLists.template.cmake (shared with all other directories),
### or create a derived template in src/templates/edit_straightener.cmake,
### then re-run ./make-cmake.py

set(SOURCES edit_straightener_factory.cpp editstraightener.cpp
            editstraightenerdialog.cpp)

set(HEADERS edit_straightener_factory.h editstraightener.h
            editstraightenerdialog.h)

set(RESOURCES editstraightener.qrc)

set(UI editstraightener.ui)

add_library(edit_straightener MODULE ${SOURCES} ${HEADERS} ${RESOURCES} ${UI})

target_include_directories(edit_straightener
                           PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(edit_straightener PUBLIC common)

set_property(TARGET edit_straightener PROPERTY FOLDER Plugins)

set_property(TARGET edit_straightener PROPERTY RUNTIME_OUTPUT_DIRECTORY
                                               ${MESHLAB_PLUGIN_OUTPUT_DIR})

set_property(TARGET edit_straightener PROPERTY LIBRARY_OUTPUT_DIRECTORY
                                               ${MESHLAB_PLUGIN_OUTPUT_DIR})

install(
    TARGETS edit_straightener
    DESTINATION ${MESHLAB_PLUGIN_INSTALL_DIR}
    COMPONENT Plugins)
