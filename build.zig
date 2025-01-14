const std = @import("std");
const pkgs = @import("deps.zig").pkgs;

const package_name = "json";
const package_path = "src/json.zig";

const json_pkg = std.build.Pkg{
    .name = package_name,
    .source = .{ .path = package_path },
    .dependencies = &[_]std.build.Pkg{
        pkgs.concepts,
        pkgs.getty,
    },
};

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    tests(b, mode, target);
    docs(b);
    clean(b);
}

fn tests(b: *std.build.Builder, mode: std.builtin.Mode, target: std.zig.CrossTarget) void {
    const test_all_step = b.step("test", "Run tests");
    const test_ser_step = b.step("test-ser", "Run serialization tests");
    const test_de_step = b.step("test-de", "Run deserialization tests");

    addTest(b, mode, target, test_all_step, test_ser_step, "src/ser.zig");
    addTest(b, mode, target, test_all_step, test_de_step, "src/de.zig");
}

fn docs(b: *std.build.Builder) void {
    const cmd = b.addSystemCommand(&[_][]const u8{
        "zig",
        "build-obj",
        "-femit-docs",
        package_path,
    });

    const docs_step = b.step("docs", "Generate project documentation");
    docs_step.dependOn(&cmd.step);
}

fn clean(b: *std.build.Builder) void {
    const cmd = b.addSystemCommand(&[_][]const u8{
        "rm",
        "-rf",
        "zig-cache",
        "docs",
        "*.o",
        "gyro.lock",
        ".gyro",
    });

    const clean_step = b.step("clean", "Remove project artifacts");
    clean_step.dependOn(&cmd.step);
}

fn addTest(
    b: *std.build.Builder,
    mode: std.builtin.Mode,
    target: std.zig.CrossTarget,
    all_step: *std.build.Step,
    step: *std.build.Step,
    comptime path: []const u8,
) void {
    const t = b.addTest(path);
    t.setTarget(target);
    t.setBuildMode(mode);
    pkgs.addAllTo(t);

    step.dependOn(&t.step);
    all_step.dependOn(step);
}

//pub fn build(b: *std.build.Builder) void {
//const mode = b.standardReleaseOptions();
//const target = b.standardTargetOptions(.{});

//// Tests
//const step = b.step("test", "Run library tests");
//const t = b.addTest(package_path);

//t.setBuildMode(mode);
//t.setTarget(target);
//pkgs.addAllTo(t);
//t.addPackage(json_pkg);
//step.dependOn(&t.step);
//}
