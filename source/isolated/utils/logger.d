﻿module isolated.utils.logger;

public import std.conv : to;

import Abort = core.internal.abort;
import std.stdio;
import std.exception;
import std.conv;
import std.traits;

// Casts @nogc out of a function or delegate type.
auto assumeNoGC(T) (T t) if (isFunctionPointer!T || isDelegate!T)
{
    enum attrs = functionAttributes!T | FunctionAttribute.nogc;
    return cast(SetFunctionAttributes!(T, functionLinkage!T, attrs)) t;
}

struct Logger
{
	@trusted nothrow:

	static void info(T : string)(T info, string filename = __FILE__, size_t line = __LINE__) {
		try {
			stdout.writefln("INFO (%s|%d) : %s", filename, line, info);
		} catch(ErrnoException ex) {
			abort("Error : " ~ collectExceptionMsg(ex));
		} catch(Exception ex) {
			abort("Error : " ~ collectExceptionMsg(ex));
		}
	}

	static void info(T)(T info, string filename = __FILE__, size_t line = __LINE__) {
		T copy = info;
		try {
			Logger.info!string(to!string(copy), filename, line);
		} catch(Exception ex) {
			abort("Error : " ~ collectExceptionMsg(ex));
		}
	}

	static void warning(string warning, string filename = __FILE__, size_t line = __LINE__) {
		try {
			stdout.writefln("WARNING (%s|%d) : %s", filename, line, warning);
		} catch(ErrnoException ex) {
			abort("Error : " ~ collectExceptionMsg(ex));
		} catch(Exception ex) {
			abort("Error : " ~ collectExceptionMsg(ex));
		}
	}

	static void error(string error, string filename = __FILE__, size_t line = __LINE__) nothrow @nogc {
		try {
			assumeNoGC( (string s1, string f1, size_t l1, string e1) {
				stderr.writefln(s1, f1, l1, e1);
			})("ERROR (%s|%s) : %s", filename, line, error);
		} catch(Exception ex) {
		}
	}

	static void error(T)(T error, string filename = __FILE__, size_t line = __LINE__) nothrow @nogc {
		static if(is(typeof(T) == char)) {
			immutable(char)[1] c; c[0] = error;
			error(c, filename, line);
		}
	}
}

void abort(T)(T value = "", string filename = __FILE__, size_t line = __LINE__) @trusted nothrow {
	Logger.error(value, filename, line);
	try { readln(); }
	catch(Exception ex) {}
	Abort.abort("");
}