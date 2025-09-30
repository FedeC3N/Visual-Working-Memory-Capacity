#include <octave/oct.h>
#include <windows.h>

typedef void (__stdcall *Out32Func)(short portAddress, short data);

// The function: send_trigger(port, value)
DEFUN_DLD(send_trigger, args, nargout,
          "send_trigger(port, value)\nSends a trigger to the parallel port.")
{
    if (args.length() != 2)
        print_usage();

    short port = (short)args(0).int_value();
    short value = (short)args(1).int_value();

    // Load the DLL
    HINSTANCE hDLL = LoadLibrary("C:\\Windows\\System32\\inpoutx64.dll");
    if (!hDLL)
        return octave_value("Failed to load inpoutx64.dll");

    // Get the function pointer
    Out32Func Out32 = (Out32Func)GetProcAddress(hDLL, "Out32");
    if (!Out32) {
        FreeLibrary(hDLL);
        return octave_value("Failed to get Out32 function");
    }

    // Send the trigger
    Out32(port, value);
    Sleep(10);  // 10 ms pulse
    Out32(port, 0x00);

    FreeLibrary(hDLL);
    return octave_value("Trigger sent.");
}

