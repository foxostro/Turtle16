# Introduction

Snap is a statically typed, natively compiled high-level language designed for programming the Turtle16 computer system. The Snap language draws heavy influences from Swift, Rust, Zig, C, and other languages.

# Getting Started

## Building and Installing Snap

To build the Snap command line tool, open the TurtleTools Xcode project, and from the menu select Product > Archive. This will build the simulator app and the tool chain, including the Snap compiler. Select the archive and choose Distribute Content > Build Products. Choose a directory in which to save the build products and click Export. Then, use Finder to drag Simulator16.app into /Applications.

The Snap command line tool is found at Simulator16.app/Contents/Frameworks/Snap so may be run by invoking /Applications/Simulator16.app/Contents/Frameworks/Snap on the command line. You may find it convenient to create a symlink to this tool in a directory in your $PATH.

## Hello, World!

The Snap command line tool can be used to build a program whose binary image may be flashed to to EEPROM and executed on hardware, or executed in the simulator app. The program may also be built and run locally for testing.

```
USAGE:
Snap [test] [options] file...

OPTIONS:
	run        Compile the program and run immediately in a VM.
	test       Compile the program for testing and run immediately in a VM.
	-t <test>  The test suite only runs the specified test
	-h         Display available options
	-o <file>  Specify the output filename
	-S         Output assembly code
	-ir        Output intermediate representation
	-ast-dump  Print the abstract syntax tree to stdout
	-q         Quiet. Do not print progress to stdout
	-O0        Disable optimizations
```

Save this simple Hello, World! program to a text file, hello.snap:
```
puts("Hello, World!\n")
```

Build this with the following command to compile it and produce hello.program:
```
% Snap hello.snap
```

The hello.program binary image may be executed in the simulator app by running the following commands in the debugger command line:
```
load program
reset
continue
```

Please note that while you will be able to see register and memory values changing over time, Simulator support for the serial output device is incomplete and you will not see the words "Hello, World!" appear anywhere. This is a work in progress.

The compiler can build and run the program in a VM which directs serial output to standard out: Run it on the command line like so:
```
% Snap run hello.snap
instruction words used: 646
Hello, World!
cpu is halted
```

# Syntax

## Comments
```
// Comments in Snap are preceded by "//" and end at the newline.
// There are no multi-line comments in Snap.
```

## Variables
```
// Immutable variables are declared with the let keyword.
// It is not necessary to use a semicolon to end a statement
let foo: u8 = 1

// The type annotation may be omitted and the compiler will automatically deduce
// the type.
let bar = 2

// Mutable variables are declared with the var keyword.
var baz = 3
baz = 4

// Variables may be left undefined at time of declaration. In this case, the
// type annotation is necessary.
var qux: [32]bool = undefined
```

## Primitive Types
```
// A variable with a boolean type is declared using bool. Valid values are true
// and false.
var myBool: bool = true
myBool = false

// An unsigned eight-bit integer type is provided.
let myUInt8: u8 = 255

// As is an unsigned sixteen-bit integer type matching the native word size of
// the Turtle16 CPU.
let myUInt16: u16 = 65535

// Signed integers are not yet implemented.
// Integers of larger widths are not yet implemented.
```

## Literal Integers
```
// Literal integers are deduced as the smallest type that fits the literal
// value. (This may change in the future.)
let a = 1
assert(a is u8)

let b = 1000
assert(b is u16)

// Hexadecimal numbers
let c = 0xabcd

// Binary numbers
let d = 0b101010

// Unicode scalar
let e = 'a'
```

## Integer Operators
```
let p: u16 = undefined // some value goes here
let q: u16 = undefined // some value goes here
var a: u16 = undefined
a = p + q  // addition
a = p - q  // subtraction
a = p * q  // multiplication
a = p / q  // division
a = p % q  // modulus
a = p & q  // bitwise and
a = p | q  // bitwise or
a = p ^ q  // bitwise xor
a = ~p     // bitwise negation
a = p == q // equal
a = p != q // not equal
a = p > q  // greater than
a = p < q  // less than
a = p >= q // greater than or equal to
a = p <= q // less than or equal to
```

Currently, only unsigned types are implemented. Overlfow and underflow are well-defined to wrap around the range of values for the type. For example, 0-1 is 65535 for a u16 value.

Signed types will be guaranteed to be implemented as twos-complement with well-defined overlfow and underflow.

The Snap programming language does not include in-place arithmetic operators such as +=, -=, &c found in other languages such as C. Nor does it support increment and decrement with ++ and -- operators.

## Boolean Operators
```
let p: bool = undefined // some value goes here
let q: bool = undefined // some value goes here
var a: bool = undefined
a = !p     // not
a = p && q // and (with short-circuiting evaluation)
a = p || q // or  (with short-circuiting evaluation)
a = p == q // equal
a = p != q // not equal
```

## Pointers
```
// The unary & operator may be used to produce a pointer.
var a: u16 = 1
let ptr = &a

// Or a pointer may be produced through automatic type conversion. The pointer
// type expression prefixes the pointee type with an asterisk.
var ptr2: *u16 = a

// Rebind the pointer by reassigning it
ptr2 = ptr

// Modify the pointee with using "pointee"
ptr2.pointee = 2

// Use const to create a pointer which cannot be used to mutate the pointee.
// This pointer may itself be mutable.
var ptr3: *const u16 = a
```

There is no pointer arithmetic in the Snap programming language. For example, the following is never permitted.
```
ptr3 = ptr3 + 1 // not valid
```

## Ranges
A range may be declared with special .. syntax. The left number is the beginning and the right is the limit. The limit must be the greater of the two, and both must be positive u16 values. The range is defined to include all values x where begin <= x < limit. In the following example, the value 1000 is not included in the range. Ranges are commonly used in array slicing and loops.
```
// Declare a range
let range: Range = 0..1000

// It's also possible to get the begin and limit of a range like so
let rangeBegin = range.begin
let rangeLimit = range.limit
```

## Arrays
```
// Define an array with a size determined at compile time
let a = [_]u8{1, 2, 3, 4, 5, 6, 7, 8, 9}
let b = [9]u8{1, 2, 3, 4, 5, 6, 7, 8, 9}

// Copy an array
var c: [9]u8 = a

// Access a single element of an array
let c0 = c[0]
c[0] = 42

// Get the number of elements in an array
let n = a.count

// A string literal is syntax sugar for an [_]u8 array literal where the
// elements of the array are the UTF-8 encoded bytes of the string.
let s = "a UTF-8 string is an array of bytes"
let c: u8 = s[0]
```

Additionally, a string may contain any of several escape sequences:
* '\t' -- Tab character
* '\n' -- Newline
* '\r' -- Carriage return
* '\"' -- Double quote
* '\'' -- Single quote
* '\\' -- Backslash
* '\0' -- Nul character

## Array Slices
```
// An array slice is a pointer and a length determined at runtime. Create a
// slice from an array by subscripting the array with a value of a Range type.
let str = "Hello, World!"
let slice1 = str[0..6] // "Hello,"
let slice2 = slice1[0..5] // "Hello"

// Get the number of elements in a slice
let n = slice2.count
```

## Casting and Conversions
```
// Convert a value to a different type with the as keyword
let a: u8 = 1
let b = a as u16

// Converting an array will copy the array and convert each element individually
let c = [_]u8{1, 2, 3}
let d = c as [_]u16
```

## Automatic type conversions
Some type conversions are automatic.
```
// Automatic conversions in integer arithmetic will convert one side of a binary
// expression to the wider of the two types
let a = 1 + 1000 // a is u16

// The address of a value is automatically taken to convert to a pointer.
let b: *u16 = a

// Arrays are automatically converted to array slices
let arr = [_]u8{1, 2, 3}
let slice: []u8 = arr
```

## Unsafe Bitcast
```
// It's occasionally useful to perform an unsafe cast to reinterpret the
// in-memory representation of a value as a different type. For example,
// hardware may provide a memory-mapped register at an particular address and it
// would be useful to have a pointer to that address.
let ptr: *u16 = 0xabcd bitcastAs *u16
```

## Structs
```
// Declare a struct like so
struct Point {
	x: u16,
	y: u16
}

// Declare an instance of a struct
let p1 = Point {
	.x = 1,
	.y = 2
}

// Declare a struct with undefined contents and set the values of members later.
var p2: Point = undefined
p2.x = 1
p2.y = 2

// Declare a struct with some fields left undefined
let p3 = Point { .x = 1 }

// It is not necessary to use a special operator or syntax to access struct
// members through a pointer. Use the standard dot syntax.
let p4: *Point = p2
p4.x = 3
p4.y = 4
```

## Unions and Is
```
// Define a tagged union using the | operator in a type annotation.
let q: u8 | bool = false

// Test the type of a union value at runtime.
let c = q is u8 // false

// Use the "is" keyword to test the type of any other value too.
let a = p is bool // true
let b = p is *bool // false
```

## Typealias
```
// Create a type alias to create more convenient names for awkward types.
typealias Foo = u8 | bool
let a: Foo = false
```

## If
```
// If is a statement. Parentheses are not required. The curly braces are always
// required, however.
if 1 + 1 == 2 {
	// then branch
} else {
	// else branch
}
```

## While
```
// While loops don't require parentheses either and also require curly braces.
var i = 0
while i < 10 {
	i = i + 1
}
```

## For
```
// For loops can iterate over the elements of a range
// The curly braces are always required.
for i in begin..limit {

}

// They can also iterate over the elements of an array
let arr = [_]u8{1, 2, 3, 4, 5, 6, 7, 8, 9}
for i in arr {

}

// Or of an array slice
for i in arr[0..3] {

}

// C-style for loops are not supported in Snap.
```

## Match
```
// The match statement allows convenient type testing of union values
var r: u8 = 0
var a: u8 | bool = 0
match a {
    (foo: u8) -> {
		r = 1
    },
    (bar: bool) -> {
		r = 2
    }
}
```

## Functions
```
// Create a function with no return value or parameters.
func foo() {
	puts("hello")
}

// Specify the return value with an arrow at the end of the signature.
func bar() -> bool {
	return true
}

// Specify parameters in parentheses with labels and type annotations.
func baz(aa: u8, bb: u16) -> u16 {
	return aa + bb
}

// The labels are not used at the function call site.
let r1 = baz(1, 1000)

// Functions may be nested. These inner functions have access to the enclosing
// lexical scopes.
func qux(aa: u8, bb: u16) -> u16 {
	let c = 1
	func quux(aa: u8) {
		return aa + c
	}
	return quux(aa) + bb
}

// Record a function pointer and use the pointer to invoke the function later.
var ptr = *func(aa: u8, bb: u16) -> u16 = undefined
ptr = &baz
ptr = qux
let r2 = ptr(1, 1)

// Proper closures and lambda expressions are not yet implemented.
```

## Struct Methods
```
struct Point {
	x: u16
	y: u16
}

// It is possible to add methods to a struct type using the "impl" keyword.
// These are added to the namespace of the struct itself.
impl Point {
	func add(p1: *Point, p2: *Point) -> Point {
		return Point {
			.x = p1.x + p2.x,
			.y = p1.y + p2.y
		}
	}
}

// Possibly across more than one impl block.
impl Point {
	func sub(p1: *Point, p2: *Point) -> Point {
		return Point {
			.x = p1.x - p2.x,
			.y = p1.y - p2.y
		}
	}
}

let p1 = Point { .x = 1, .y = 1 }
let p2 = Point { .x = 1, .y = 1 }
let p3 = Point.add(p1, p2)
let p4 = Point.sub(p1, p2)
```

## Traits
A trait defines an abstract protocol or interface for interacting with a struct type. Currently, traits provide dynamic dispatch through a vtable. In the future, the compiler will use traits as constraints on generic type parameters.

The first parameter of each function in the interface may optionally be a pointer to the trait type. In this case, a conforming implementation method is one that has a type that's either a pointer to the trait type or has a type that's a pointer to the concrete struct instance.

TODO: This is confusing. The compiler should be changed to use a special Self keyword as a placeholder in this case.
```
// Define a trait and the collection of functions that make up its interface.
trait Serial {
	func write(self: *Serial, bytes: []u8)
	func read(self: *Serial) -> []8
}
```

Any struct may implement a trait by defining an impl-for block with definitions of required methods.
```
struct SerialFake {
	cannedData: []u8
}

impl Serial for SerialFake {
	func write(self: *SerialFake, bytes: []u8) {
		puts(bytes)
	}

	func read(self: *SerialFake) -> []8 {
		return self.cannedData
	}
}
```

Trait objects have their own set of rules about automatic type conversions. A concrete struct conforming to a trait may be seamlessly and automatically converted to the representing trait object.
```
let concreteObject = SerialFake {}
let traitObject: Serial = concreteObject
```


## Modules and Import
Code may be written across multiple source files. Use the import keyword to instruct the compiler to import another source file as a module. Public symbols found in the module are imported into the global namespace. Private symbols (the default) are not imported.
```
// Import a module defined in a file named MyModule.snap
import MyModule

// Mark a variable as public
public let myVariable = 0xabcd

// Mark a type as public
public struct MyStruct {

}

// Mark a function as public
public func foo() {

}

// It's possible to mark a symbol as private too.
// This is not often necesary as private is the default.
private let myPrivateVar = 0xbeef
```

## Assert
The assert statement asserts that an expression evaluates to true. If at runtime, the expression does not evaluate to true then the program halts with an appropriate diagnostic message.
```
assert(1 + 1 == 2) // passes
assert(2 + 2 == 5) // trips the assert
```

## Test Declarations
Unit tests may be declared using the test keyword. These tests are executed when invoking the compiler with the "test" verb. In this mode, a failed assertion produces a diagnostic message and halts the test.

A program always executes the statements in the top-level body of the main source file and then executes either the testMain() or main() function. The main() function is optional and may be omitted. The testMain() function is automatically generated by the compiler and contains the test suite runner.
```
// Declare a unit test.
test "A test name goes here" {
	assert(1 + 1 == 2)
}

// Declare a main function to execute when not running tests.
func main() {
	puts("not running for testing right now\n")
}
```

## Compiler Intrinsics
```
// Halt execution immediately
hlt()
```

## Runtime support
The `None` type is an empty placeholder that may be used in a union to form a sort of optional type. The value `none` has this type.
```
var maybeSerial: Serial | None = none

match maybeSerial {
    (serial: Serial) -> {
		// something
    },
    (none: None) -> {
		// something else
    }
} 
```

Put a single byte from an UTF-8 encoded string to the output device.
```
func putc(c: u8)
```

Put a a UTF-8 encoded string to the output device.
```
func puts(s: []const u8)
```

Print the specified diagnostic message and terminate the program.
```
func panic(message: []const u8)
```