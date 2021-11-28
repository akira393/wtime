package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

var (
	Version  = "unset"
	Revision = "unset"
)

const (
	ExitCodeOk int = iota
	ExitCodeError
)

func main() {
	if err := run(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v", err)
		os.Exit(ExitCodeError)
	}
	os.Exit(ExitCodeOk)
}

//520(0840)を分に変更
func mTot(i int) int {
	h := i / 60
	m := (i - i/60*60)
	return h*100 + m

}

func caluc(i int, p int) int {
	//分を抽出(40の部分)
	// (i-i/100*100)=>40
	// 時を抽出(08の部分)し，60をかけることによって分を産出
	// i/100*60 //=>480
	// 分に変換して割合をかける
	t := ((i - i/100*100) + i/100*60) * p / 100

	return mTot(t)

}

func run(args []string) error {
	// if len(args) != 2 {
	// 	return fmt.Errorf("指定された引数の数が間違っています。:%v\n", len(args)-1)
	// }
	// if len(args[1]) != 4 {
	// 	return fmt.Errorf("引数が指定のフォーマットではありません．例:0840\n")
	// }//
	i, _ := strconv.Atoi(args[1]) // int: 0840

	// fmt.Println(caluc(i, 85))
	fmt.Println("------------------------")
	fmt.Printf("あなたの作業時間は:%v\n", args[1])
	fmt.Println("------------------------")

	fmt.Printf("直さ率:%v%%の場合: %v\n", 80, caluc(i, 80))
	fmt.Printf("直さ率:%v%%の場合: %v\n", 85, caluc(i, 85))
	fmt.Printf("直さ率:%v%%の場合: %v\n", 90, caluc(i, 90))
	fmt.Printf("直さ率:%v%%の場合: %v\n", 100, caluc(i, 100))
	fmt.Println("------------------------")
	fmt.Print("終了するにはenterを押してください? ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	return nil
}
