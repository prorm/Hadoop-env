# How to practise every lab program

A general guide for this practice machine (GitHub Codespaces or Docker). The **code** for each program is in
the *Byheart Lab Manual*; this page is the **how to run it** part, the same for every program.

Below, `<USN>` means your USN folder, e.g. `1MS24CI091` (type `ls ~` to see yours).

---

## 0. Getting in

| | |
|---|---|
| Codespaces | github.com/codespaces → open your codespace → terminal with **Ctrl + `** |
| Docker | double-click `start-lab.bat` (Windows) or run `./start-lab.sh` |
| Go home first | `cd ~` → prompt shows `rit@rit:~$` |
| Cheat sheet | `lab-help` |
| Paste in terminal | **Ctrl + Shift + V** |
| Second terminal | **+** in the terminal panel (it needs `source Bash.sh` again) |
| Finished | Codespaces: **stop** the codespace at github.com/codespaces. Docker: `exit` |

---

## 1. Where everything is

```
~/<USN>/hadoop-3.2.2          Programs 1-3 (HDFS, MapReduce in Java)
~/spark-4.0.1-bin-hadoop3     Programs 4-6 (Spark in Python)
~/DataSet/                    all dataset files
```

### The datasets

```
ls ~/DataSet
```

| File in `~/DataSet` | Used in | Copy it with a short name |
|---|---|---|
| `Weather Report Data .txt.txt` | Program 1 (HDFS), Program 4 (weather) | `cp ~/DataSet/"Weather Report Data .txt.txt" weather.txt` |
| `WordCount Input.txt` | Program 2 (word count) | `cp ~/DataSet/"WordCount Input.txt" input.txt` |
| `Female and Male Employees Data.txt.txt` | Program 3 (employee) | `cp ~/DataSet/"Female and Male Employees Data.txt.txt" employee.txt` |
| `Sales Records _Input.csv` | Program 5 (sales) | `cp ~/DataSet/"Sales Records _Input.csv" sales.csv` |
| `Odd or Even .txt.txt` | Program 2 twist (odd/even count) | `cp ~/DataSet/"Odd or Even .txt.txt" numbers.txt` |
| `Custome.txt.txt`, `Order.txt.txt` | Program 6 twist (join) | `cp ~/DataSet/Custome.txt.txt customer.txt` and `cp ~/DataSet/Order.txt.txt order.txt` |
| `Earthquake Data.csv`, `Insurance Data.csv`, `Student_Details.txt.txt`, `Retail Transactions.txt` | extra practice / changed questions | same pattern |

**The names contain spaces, so always put them in quotes.** Copy the dataset **into the folder you are
working in** before you run the program.

To see what a file looks like before writing code: `head -5 sales.csv`, and to count its lines: `wc -l sales.csv`.

---

## 2. One-time setup: Bash.sh (exactly like the lab)

Hadoop and Spark are **not** ready until you make `Bash.sh` in their folder and `source` it.

**Hadoop** (3 lines):
```
cd ~/<USN>/hadoop-3.2.2
nano Bash.sh
```
```
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
export PATH=$PATH:$(pwd)/bin
export CLASSPATH=$(hadoop classpath)
```
Save in nano: **Ctrl+O, Enter, Ctrl+X**.

**Spark** (the first 2 lines only):
```
cd ~/spark-4.0.1-bin-hadoop3
nano Bash.sh
```
```
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
export PATH=$PATH:$(pwd)/bin
```

**In every new terminal:** `cd` into the folder, then `source Bash.sh`.
- Use `source`, not `bash Bash.sh`, because `bash` forgets the settings.
- Run it from inside the folder, because `$(pwd)` means "this folder".

---

## 3. Is it working? (health checks)

### Hadoop
```
cd ~/<USN>/hadoop-3.2.2
source Bash.sh
echo $JAVA_HOME          # /usr/lib/jvm/java-17-openjdk-amd64
echo $PATH               # ends with .../hadoop-3.2.2/bin
echo $CLASSPATH          # long list of hadoop-3.2.2/share/hadoop/... folders
hadoop version           # first line: Hadoop 3.2.2
java -version            # openjdk version "17..."
```
If `hadoop version` prints `Hadoop 3.2.2`, Hadoop is working.

### Spark
```
cd ~/spark-4.0.1-bin-hadoop3
source Bash.sh
spark-submit --version   # shows version 4.0.1
spark-shell              # the Spark logo appears; quit with Ctrl+C (or :quit)
pyspark                  # Python version of the shell; try  sc.parallelize([1,2,3]).sum()  then exit()
```

### HDFS (only for Program 1)
```
hdfs-on                  # prompt now starts with (hdfs)
jps                      # must list NameNode and DataNode (and Jps)
hdfs dfs -ls /           # works without errors
```
- **Web UI:** in Codespaces, open the **Ports** tab and click the globe icon next to **9870**. In Docker, go to <http://localhost:9870>.
- **Finished?** Run `hdfs-off`. That's **required before Programs 2-6.** `hdfs-stop` shuts HDFS down completely.

---

## 4. Program 1: HDFS commands (general pattern)

```
hdfs-on
cd ~/<USN>/hadoop-3.2.2
source Bash.sh
cp ~/DataSet/"Weather Report Data .txt.txt" weather.txt
```
Every HDFS command is **`hdfs dfs -` + a Linux command**. Paths starting with `/` are inside HDFS.

| Want to | Command |
|---|---|
| make folders | `hdfs dfs -mkdir -p /data/weather` |
| upload | `hdfs dfs -put weather.txt /data/weather/` |
| list / read | `hdfs dfs -ls /data/weather` · `hdfs dfs -cat /data/weather/weather.txt` |
| copy / move | `hdfs dfs -cp <src> <dst>` · `hdfs dfs -mv <src> <dst>` |
| download | `hdfs dfs -get /data/weather/weather.txt copy.txt` |
| permissions | `hdfs dfs -chmod 640 <file>` · `hdfs dfs -chgrp students <file>` · `hdfs dfs -chown rit:students <file>` |
| size / info | `hdfs dfs -du -h /data/weather` · `hdfs dfs -stat "%n: %b bytes, block size %o, replication %r" <file>` |
| blocks | `hdfs fsck <file> -files -blocks -locations` · `hdfs getconf -confKey dfs.blocksize` |
| delete | `hdfs dfs -rm <file>` · `hdfs dfs -rm -r /data/weather` |

When finished: **`hdfs-off`**.

---

## 5. Programs 2 and 3: MapReduce in Java (same 5 commands every time)

Replace `NAME` with the program's package name (`wordcount`, `employee`, ...). It **must** match the
`package NAME;` line at the top of your `driver.java`.

```
cd ~/<USN>/hadoop-3.2.2
source Bash.sh
mkdir -p Programs/NAME && cd Programs/NAME
nano driver.java                                  # type the code from the manual
cp ~/DataSet/"<dataset file>" input.txt           # copy the dataset here

javac -d . *.java                                 # 1. compile  -> creates a NAME/ folder of .class files
echo Main-Class: NAME.driver > Manifest.txt       # 2. manifest -> which class to start
jar cfm NAME.jar Manifest.txt NAME/*.class        # 3. pack     -> NAME.jar
hadoop jar NAME.jar input.txt output              # 4. run      -> input file, NEW output folder
cat output/*                                      # 5. result
```

**Examples:**
- **Program 2:** `NAME` = `wordcount`, dataset `"WordCount Input.txt"`.
- **Program 3:** `NAME` = `employee`, dataset `"Female and Male Employees Data.txt.txt"` copied as `employee.txt`. The run line is then `hadoop jar employee.jar employee.txt output`.
- **Separate files:** if the lab sheet gives you `driver.java`, `mapper.java` and `reducer.java`, the same commands work, because `*.java` compiles them all.

**Checking it worked:**
- `ls output` shows `_SUCCESS` and `part-00000`.
- The log ends with counters such as `Map input records=...`.

**Running again:** first `rm -r output`, because Hadoop refuses to overwrite.

**After changing the code:** run all four commands again, compile → manifest → jar → run. Old `.class` files don't update themselves.

---

## 6. Programs 4-6: Spark in Python (same pattern every time)

```
cd ~/spark-4.0.1-bin-hadoop3
source Bash.sh
nano NAME.py                                      # type the code from the manual
cp ~/DataSet/"<dataset file>" <shortname>         # copy the dataset here
spark-submit NAME.py <input> <output folder(s)>
cat <output folder>/*
```

| Program | Copy dataset | Run | See result |
|---|---|---|---|
| 4 Weather | `cp ~/DataSet/"Weather Report Data .txt.txt" weather.txt` | `spark-submit weather.py weather.txt maxtemp` | `cat maxtemp/*` |
| 5 Sales | `cp ~/DataSet/"Sales Records _Input.csv" sales.csv` | `spark-submit sales.py sales.csv totalsales products payment` | `cat totalsales/*` · `cat products/*` · `cat payment/*` |
| 6 Pair RDD | (data is typed inside the program) | `spark-submit pairrdd.py 2>/dev/null` | printed on screen |

**What the arguments mean:** `sys.argv[1]` is the first word after the `.py` name, `sys.argv[2]` the second, and so on.

**INFO lines:** Spark prints many of them, and that's normal. Add `2>/dev/null` to hide them when you only want your `print` output.

**Output folders:** these contain `part-00000`, `part-00001`, ... `cat folder/*` shows them all together.

**Running again:** first `rm -r maxtemp` (or whichever output folder you used).

**Trying a line before putting it in the program:** use `pyspark`, where `sc` is ready-made.
```
>>> rdd = sc.textFile("weather.txt")
>>> rdd.take(2)
```

---

## 7. When something goes wrong

| You see | Fix |
|---|---|
| `hadoop: command not found` / `spark-submit: command not found` | `cd` into that folder, `source Bash.sh` (new terminals need it again) |
| `package org.apache.hadoop... does not exist` when compiling | CLASSPATH not set: `cd ~/<USN>/hadoop-3.2.2 && source Bash.sh`, then go back |
| `Output directory ... already exists` | `rm -r output` (or the folder you named) |
| `Input path does not exist: hdfs://localhost:9000/...` | the terminal is in HDFS mode: `hdfs-off` |
| `Input path does not exist: file:/...` | dataset not copied into this folder, or a typo: `ls` to check |
| `No such file or directory` with a dataset name | the name has spaces: put it in quotes |
| `Could not find or load main class` | the `package` name, the folder name and `Main-Class:` must all match |
| Python `IndexError` / `ValueError` | the file has a header line or a different format: `head -3 <file>` and adjust the split or index |
| `hdfs dfs ...` gives `Input/output error` (first start) | `hdfs-stop`, then `hdfs-on` again |
| `hdfs dfs -ls /` lists Linux folders (bin, home, usr) | you're not in HDFS mode: `hdfs-on` |
| Messed everything up | `lab-reset` (moves your work to `~/lab-backup-<time>/`, wipes HDFS) |

---

## 8. A practice routine that works

1. **First time:** follow the manual for each program, typing the code yourself rather than pasting it.
2. **Exam practice:** `lab-reset`, set a timer, and do one program **from memory**: Bash.sh, code, compile or submit, output.
3. **Check:** compare your output with the expected output printed in the manual.
4. **Changed questions:** try the edits in the manual's *If they change the question* table, one at a time.
5. **Night before:** the manual's one-page revision plus one full run of all six programs.
6. **Install question:** `lab-fresh-install` lets you practise extracting Hadoop and Spark from the tarballs. `lab-fresh-install --restore` undoes it.
