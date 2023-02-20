#include <Python.h>
#include <pybind11/embed.h>
#include <pybind11/eval.h>
#include <iostream>

namespace py = pybind11;

void doFile(const char *str)
{
    py::scoped_interpreter guard{};
    py::object scope = py::module_::import("__main__").attr("__dict__");
    try {
        py::eval_file(str, scope);
    }
    catch (const std::exception &e) {
        std::cout << "Horrible error: " << e.what() << std::endl;
    }
}

void callNative(const char * strclbk)
{
    auto mod = py::module::import("package");
    auto funcraw = mod.attr(strclbk);

    funcraw();
}