Commons-DBCP-monitoring
=======================

Monitor what threads are using connections from the DBCP pool, and waiting for connection. Generate a nice table to understand what is happening.

Usage:

1. Replace your application's `commons-dbcp-1.4.jar` with [commons-dbcp-1.4-monitored.jar](https://raw.github.com/nicolas-raoul/Commons-DBCP-monitoring/commons-dbcp-1.4-monitored.jar) (rename it to pretend it is really the same JAR file)
2. Run your application, making sure the output is directed to a log file
3. When you want, generate a graph:
   1. Run: `./generate-dbcp-graph.sh <your-output-file.log>`
   2. Wait while `dbcp-connected-by-thread.csv` and `dbcp-waiting-by-thread.csv` are generated.
   3. Open the CSV files with any spreadsheet program (like LibreOffice) and use conditional formatting to end up with something like this:

![Threads using connections](https://raw.github.com/nicolas-raoul/Commons-DBCP-monitoring/master/screenshots/threads-using-connections.png)
![Combined using/waiting graph](https://raw.github.com/nicolas-raoul/Commons-DBCP-monitoring/master/screenshots/combined-graph.png)

---

Compilation:

1. Download the [Commons DBCP 1.4 source code](http://ftp.jaist.ac.jp/pub/apache//commons/dbcp/source/commons-dbcp-1.4-src.tar.gz)
2. Uncompress it.
3. Copy all files from the `patch-for-commons-dbcp-1.4-src` directory to into the uncompressed directory
4. Run Ant
