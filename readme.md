A Delphi Smart Pointer prioritising ownership and transfer of ownership.
========================================================================

Inspiration taken from several sources, most notably Marco Cantu (Object Pascal Handbook),
but modified to more clearly communicate ownership and transfer of ownership.

There are two reasons why a Smart Pointer is desired:
* Automatic resource management.
* Communication about resource management with other parts of the program.

Delphi has a number of data types that are automatically; the most flexible of which are:
* Records (and variations).
* Interfaces, though great care needs to be taken during implementation and use.

This implementation focuses on managing object references.

This version does *not* implicitly convert between unmanaged objects, and managed objects.
If it did, that would make SharedPointer automatically take ownership of such objects, and this might not have been the developer's intention: Such an error would easily result in a double-free, or an early-free.

Delphi, however, has a long history of containers and collections "owning" their objects, so some concessions have been made for `TSharedList<T>`, which automatically owns it's objects, similar to existing collections in Delphi.

Some limitations that I could not resolve with Delphi:
* There is no way to mark the shared pointer as `invalid` - the developer, once the smart pointer has been released, must take care not to use the reference again, otherwise a runtime error will result. (Internally, the reference is nil'ed, but it is not a compiler error to attempt to use it).
* There is no way to overload the 'dot operator', similar to how smart pointers are done in C++.  This does have the impact of making effective use of the shared pointer considerably more tedious.
* Destruction order is undefined.  Hopefully this is not a problem, however, if it is a problem, then it will be recommended to `.Release.Free` the pointer manually, as appropriate, in a try/finally block.


Description of `TShared<T>`:
----------------------------

`TShared<T>` is an implementation of Smart Pointers in Delphi.

It is implemented as a generic advanced record, and by default, it does not contain an object reference: To use it, an object must be assigned to it either by using the constructor, or by calling `.Assign`.

The actual lifetime of the object reference is managed by a reference counted interface in the FFreeTheValue private field of the record.

If neccessary, a custom deallocator can be provided, however this is rarely needed.

In normal use, the managed object can be used by using the 'Temporary' property (implemented as a function, here): This provides a "temporary" reference to the object.
 - This *must not* be provided to any routine that expects to take ownership of the object.

If a transfer of ownership is required, there are two options:
* The `TShared<T>` itself can be transferred. This will actually *share* ownership, so it's not a transfer of ownership in the strict sense of the term.  The last scope to hold a copy of the object will release it automatically.
* Alternatively, particularly when dealing with code that does not use `TShared<T>`, the `.Release` function can be used.

When using `.Release`, the TShared<T> is invalidated, and must not be used again (except to store another object reference, in which case it can be used again).


License:
--------

MIT License.


Copyright 2018 John Chapman.
