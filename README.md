# Sparrow

Sparrow is an [entity-component-system](https://en.wikipedia.org/wiki/Entity_component_system) (ECS) library using sparse sets. It is written in [Lua](https://www.lua.org/), and is primarily intended for use with [LuaJIT](https://luajit.org/). In Sparrow, an entity is a number, a component is a string, and a system is a function. Beyond the ECS terms, most of the terminology in Sparrow is borrowed from the [relational model](https://en.wikipedia.org/wiki/Relational_model). There are columns, identified by components (strings). There are also rows, identified by entities (numbers). In the intersections between columns and rows are optional cells. The cells contain the actual values that you want to store. The columns and rows together form a single sparse database table.


## Columnar storage

The columns are the primary containers for storing values, while the rows are secondary containers. Each column has three mappings: a sparse mapping from entity to index, a dense mapping from index back to entity, and another dense mapping from index to value. A column can optionally be created with a C data type to store values linearly in memory using a C array. The supported data types are primitives and structs. The data types and arrays are managed using [LuaJIT's FFI](https://luajit.org/ext_ffi.html), a [foreign function interface](https://en.wikipedia.org/wiki/Foreign_function_interface). Linear memory access makes efficient use of the [CPU cache](https://en.wikipedia.org/wiki/CPU_cache), a hallmark of [data-oriented design](https://en.wikipedia.org/wiki/Data-oriented_design).


## Data processing

Sparrow supports queries for processing groups of columns. A query can select multiple columns and call a system (function) for each matching row. Even systems that are [pure functions](https://en.wikipedia.org/wiki/Pure_function) can read, write, add and remove cells. Non-pure systems can have arbitrary side effects, with some restrictions.
