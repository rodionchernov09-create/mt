cmake_minimum_required(VERSION 3.16)

project(Turing VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Подключаем только то, что есть
find_package(Qt6 REQUIRED COMPONENTS Core Quick)

qt_standard_project_setup()

qt_add_executable(appTuring
    main.cpp
    TuringMachine.cpp
    TuringMachine.h
)

target_link_libraries(appTuring
    PRIVATE
        Qt6::Core
        Qt6::Quick
)

set_target_properties(appTuring PROPERTIES
    WIN32_EXECUTABLE TRUE
)
