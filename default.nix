{ lib, stdenv, package-set, selection }:
let
    json = builtins.fromJSON (builtins.readFile package-set);
    packages = builtins.mapAttrs package json;

    packageUrl = repo: version:
        "${lib.strings.removeSuffix ".git" repo}/archive/${version}.tar.gz";

    package = name: definition: {
        name = name;
        path = builtins.fetchTarball {
            url = packageUrl definition.repo definition.version;
        };
        dependencies = map (p: packages.${p}) definition.dependencies;
    };

    closure = package:
        [{ name = package.name; value = package.path; }] ++
        builtins.concatMap closure package.dependencies;
    closurePaths = c: builtins.attrValues (builtins.listToAttrs c);
in
    closurePaths (builtins.concatMap (p: closure packages.${p}) selection)
