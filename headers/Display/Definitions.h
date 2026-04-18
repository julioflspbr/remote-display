#ifndef DISPLAY_DEFINITIONS_H
#define DISPLAY_DEFINITIONS_H

#define BYTE_SIZE 8

namespace Display {
	typedef char					Byte;
	typedef int						Pin;
	typedef unsigned char	TextLength;

	enum class RegisterSelect {
		Command, Data
	};

	enum class ReadWrite {
		Write, Read 
	};

	enum class CursorDirection {
		Decrement,
		Increment
	};

	struct FunctionSet {
		enum class DataLength {
			FourBits,
			EightBits
		};

		enum class Lines {
			OneLine,
			TwoLines
		};

		enum FontSize {
			EightPixels,
			TenPixels
		};
	};

	enum class Line {
		First = 	0x00,
		Second = 	0x40
	};

	namespace Adapter {
		struct Pins {
			Pin rs;
			Pin rw;
			Pin e;
			Pin data[BYTE_SIZE];
		};

		enum class Command {
			Clear 					= 1 << 0,
			EntryMode				= 1 << 2,
			DisplayControl	= 1 << 3,
			FunctionSet			= 1 << 5,
			DDRAMAddress		= 1 << 7
		};

		union Parameters {
			struct {} noParams;
			struct { CursorDirection direction; bool autoShift; } entryMode;
			struct { bool isDisplayOn; bool isCursorOn; bool isBlinkOn; } displayControl;
			struct { FunctionSet::DataLength dataLength; FunctionSet::Lines lines; FunctionSet::FontSize fontSize; } functionSet;
			struct { Line line; } ddramAddress;
		};
	}
}

#endif

