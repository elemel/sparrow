# Sparrow

Sparrow is an [entity-component-system](https://en.wikipedia.org/wiki/Entity_component_system) (ECS) library using sparse sets. It is written in Lua, primarily intended for use with [LuaJIT](https://luajit.org/). In Sparrow, an entity is a number, a component is a string, and a system is a function (or a callable Lua table). Beyond the ECS terms, most of the nomenclature in Sparrow is borrowed from the [relational model](https://en.wikipedia.org/wiki/Relational_model). There are columns, each uniquely identified by a component (string). There are rows, each uniquely identified by an entity (number). There are cells at the intersections of the columns and the rows. The cells are optional. You can select multiple columns in a query to iterate over all rows that intersect the columns.


## Columnar storage

The columns are the primary structures for storing and accessing data, while the rows are secondary structures for data access. Each column has three mappings: entity to index, index to entity, and index to value. A column can optionally be created with a C data type to store data linearly in an array. The C array management is implemented using [LuaJIT's FFI](https://luajit.org/ext_ffi.html), a [foreign function interface](https://en.wikipedia.org/wiki/Foreign_function_interface). The supported data types are primitives and structs. Linear data access makes efficient use of the [CPU cache](https://en.wikipedia.org/wiki/CPU_cache).
