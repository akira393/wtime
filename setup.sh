#/bin/bash
#gitginoreを追加
#readmeの編集
#タグの付け方
#タグの消し方

function touchp () {
    if [ ! -f $1 ] ;then
        mkdir -p "$(dirname "$1")" && touch  "$1"
    fi
    
}
if [ $# != 1 ]; then
    echo "引数の数が間違っています！"
    echo "cliツールの名前を入れてください．"
    exit 1
fi

go mod init "github.com/akira393/$1"

main_file="cmd/$1/$1.go"

touchp $main_file
cat <<EOF >$main_file
package main

import (
	"fmt"
	"os"
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
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v", err)
		os.Exit(ExitCodeError)
	}
	os.Exit(ExitCodeOk)
}
func run() error {

	//具体的な処理

	return nil
}

EOF

README="README.md"
touchp $README
cat <<EOF >$README

# to do
- secretsにMY_GITHUB_TOKENを登録
	- githubに登録をし，workflowでリリース作業を自動化するのならば

EOF

github_workflow=".github/workflows/release.yml"
touchp $github_workflow
cat <<"EOF" > $github_workflow

name: release
on:
  push:
    tags:
    - "v[0-9]+.[0-9]+.[0-9]+"
jobs:
  goreleaser:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v1
        with:
          fetch-depth: 1
      - name: Setup Go
        uses: actions/setup-go@v1
        with:
          go-version: 1.13
      - name: Run GoReleaser
        uses: goreleaser/goreleaser-action@v1
        with:
          version: latest
          args: release --rm-dist
        env:
          GITHUB_TOKEN: ${{ secrets.MY_GITHUB_TOKEN }}
EOF

goreleaser_file=".goreleaser.yml"
if [ ! -f $goreleaser_file ];then
touch $goreleaser_file
fi
cat <<"EOF" >$goreleaser_file
project_name: app_name
env:
  - GO111MODULE=on
before:
  hooks:
    - go mod tidy
builds:
  - main: cmd/app_name/app_name.go
    binary: app_name
    goos: # default では linux と darwin だけだけど windows 用のバイナリも作るようにしてみる
      - linux
      - darwin
      - windows
    goarch: # default では 386 と amd64 だけど今更 32bit は不要かなと
      - amd64
    ldflags: 
      - -s -w
      - -X github.com/akira393/app_name/cmd.Version={{.Version}}
      - -X github.com/akira393/app_name/cmd.BuildTag={{.Tag}}
    env:
      - CGO_ENABLED=0
archives:
  - name_template: '{{ .ProjectName }}_{{ .Os }}_{{ .Arch }}{{ if .Arm }}v{{ .Arm }}{{ end }}'
    replacements:
      darwin: Darwin
      linux: Linux
      windows: Windows
      386: i386
      amd64: x86_64
    format_overrides:
      - goos: windows
        format: zip
release:
  prerelease: auto

EOF
sed -i '' -e "s/app_name/$1/g" $goreleaser_file