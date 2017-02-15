#include <iostream>

// having fun with rvalue references
// aka why rust is a good idea

struct foo {
    foo(const char* x) : x(x) {}
    const char* x;
};

struct bar {
    bar(std::string &&x) : x(x) {}
    std::string x;
};

// lifetime(f) > lifetime(b), yay!
void modify_foo(foo &f, bar&& b) {
    f.x = b.x.c_str();
}

void call_modify_foo(foo &f) {
    char goodbye[20] = "Goodbye, world!";
    modify_foo(f, bar(std::string(goodbye)));
    std::cout << f.x << std::endl; // Goodbye, world!
}

int main() {
    char x[] = "Hello, world";
    foo f(&x[0]);
    std::cout << f.x << std::endl; // Hello, world!
    call_modify_foo(f);
    std::cout << f.x << std::endl; // uh oh
    std::cout << "yikes" << std::endl; // yikes
    std::cout << f.x << std::endl; // well at least this should do the same thing as before, right?
}
