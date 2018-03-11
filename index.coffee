s = require "shelljs";
readline = require "readline";

source = "";
target = "";
backup = "";

rl = readline.createInterface(process.stdin, process.stdout);

getSource = () =>
    return new Promise (resolve) =>
        rl.question "Absolute path of source dir: ", (input) =>
            source = input.replace(/\\/g, "/").replace(/\/$/, "");
            resolve();

getTarget = () =>
    return new Promise (resolve) =>
        rl.question "Absolute path of target dir: ", (input) =>
            target = input.replace(/\\/g, "/").replace(/\/$/, "");
            resolve();

getName = () =>
    return new Promise (resolve) =>
        rl.question "Name of backup [optional]: ", (input) =>
            backup = input;
            resolve();

checkDirs = () =>
    dirs = [source, target]

    for path in dirs
        if s.test "-e", path
            console.log """Path found: #{path}""";
        else
            console.error """Path not found: #{path}""";
            process.exit(1);

getDirs = () =>
    await getSource();
    await getTarget();
    await getName();
    rl.close();
    checkDirs();

makeBackup = () =>
    backupDirName = "";
    backupRoot = """#{target}/1-sbbackups""";
    backupFullPath = "";
    currentDate = new Date();
    unixTimestamp = currentDate.getTime();
    filesToBackup = s.ls "-RA", source;
    filesToRemove = [];
    removeFilePath = "";

    if backup != ""
        backupDirName = """#{backup}-#{unixTimestamp}""";
    else
        backupDirName = """#{unixTimestamp}""";

    if !s.test "-e", backupRoot
        s.mkdir backupRoot;

    backupFullPath = """#{backupRoot}/#{backupDirName}""";
    s.mkdir  backupFullPath;

    for file in filesToBackup
        fileSrc = """#{target}/#{file}""";
        fileDist = """#{backupFullPath}/#{file}""";

        if s.test "-d", fileSrc
            s.mkdir("#{backupFullPath}/#{file}");
            continue;

        if !s.test "-e", fileSrc
            filesToRemove.push fileSrc;
        else
            console.log "backup: " + fileSrc
            s.cp "-r", fileSrc, fileDist;

    removeFilePath = """#{backupFullPath}/remove.txt""";

    if filesToRemove.length > 0
        for file in filesToRemove
            s.echo("""'#{file}'""").toEnd(removeFilePath);

copyDir = () =>
    s.cp("-r", """#{source}/*""", target);

(() =>
    await getDirs();
    await makeBackup();
    await copyDir();
)();
