# Sparrow

Sparrow is an [entity-component-system](https://en.wikipedia.org/wiki/Entity_component_system) (ECS) library using sparse sets. It is written in Lua, primarily intended for use with [LuaJIT](https://luajit.org/). In Sparrow, an entity is a number, a component is a string, and a system is a function (or a callable Lua table). Beyond the ECS terms, most of the nomenclature in Sparrow is borrowed from the [relational model](https://en.wikipedia.org/wiki/Relational_model). There are columns, identified by components (strings). There are also rows, identified by entities (numbers). Each combination of an entity and a component can optionally identify a cell, forming a sparse data structure. The cells contain the actual values.


## Columnar storage

The columns are the primary data structures for storing and accessing values, while the rows are secondary data structures. Each column has three mappings: a sparse mapping from entity to index, a dense mapping from index back to entity, and another dense mapping from index to value. A column can optionally be created with a C data type to store values linearly in an array. The supported data types are primitives and structs. The C arrays are managed using [LuaJIT's FFI](https://luajit.org/ext_ffi.html), a [foreign function interface](https://en.wikipedia.org/wiki/Foreign_function_interface). Linear memory access makes efficient use of the [CPU cache](https://en.wikipedia.org/wiki/CPU_cache).


## Queries and systems

Sparrow supports queries for iterating over groups of columns. A query can select multiple columns and apply a system (function) to each matching row.
