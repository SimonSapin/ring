// Copyright 2015 Brian Smith.
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use std::env;
use std::path::Path;

const LIB_NAME: &'static str = "ring";

fn main() {
    for (key, value) in env::vars() {
        println!("{}: {}", key, value);
    }

    let host_str = env::var("HOST").unwrap();
    let host_triple = host_str.split('-').collect::<Vec<&str>>();

    let target_str = env::var("TARGET").unwrap();
    let target_triple = target_str.split('-').collect::<Vec<&str>>();

    let out_dir = env::var("OUT_DIR").unwrap();

    let use_msbuild = host_triple.contains(&"msvc") &&
                      target_triple.contains(&"msvc");

    let disable_opt = env::var("OPT_LEVEL").unwrap() == "0";

    // TODO: deal with link-time-optimization flag.

    let command_name;
    let args;
    let lib_path;
    if !use_msbuild {
        command_name = "make";
        // Environment variables |CC|, |CXX|, etc. will be inherited from this
        // process.
        let cmake_build_type = "RELWITHDEBINFO"; // TODO: disable_opt
        lib_path = Path::new(&out_dir).join("lib");
        args = vec![
            format!("-j{}", env::var("NUM_JOBS").unwrap()),
            format!("TARGET={}", target_str),
            format!("CMAKE_BUILD_TYPE={}", cmake_build_type),
            format!("BUILD_PREFIX={}/", out_dir),
        ];
    } else {
        // TODO: This assumes that the package is being built under a
        // {VS2013,VS2015} {x86,x64} Native Tools Command Prompt. It would be
        // nice if we didn't require that to be the case. At least it should be
        // documented.
        command_name = "msbuild";
        let platform = match target_triple[0] {
            "i686" => "Win32",
            "x86_64" => "x64",
            _ => panic!("unexpected ARCH: {}", target_triple[0])
        };
        let configuration = if disable_opt { "Debug" } else { "Release" };
        args = vec![
            format!("{}.sln", LIB_NAME),
            format!("/m:{}", env::var("NUM_JOBS").unwrap()),
            format!("/p:Platform={}", platform),
            format!("/p:Configuration={}", configuration),
            format!("/p:OutRootDir={}/", out_dir),
        ];
        lib_path = Path::new(&out_dir).join("lib");
    }

    if !std::process::Command::new(command_name)
            .args(&args)
            .status()
            .unwrap_or_else(|e| { panic!("failed to execute {}: {}",
                            command_name, e); })
            .success() {
        panic!("{} execution failed", command_name);
    }

    println!("cargo:rustc-link-search=native={}", lib_path.to_str().unwrap());
    println!("cargo:rustc-link-lib=static={}-core", LIB_NAME);
}