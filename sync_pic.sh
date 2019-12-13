#!/bin/bash
# wenfahua/2019/12/13

work_path=`dirname $0`
cd $work_path
work_path=`pwd`
echo $work_path

# typora app 存图片的默认路径
src_pic_path='/Users/wenfahua/Library/Application Support/typora-user-images'

# 修改前进行数据备份。
datename=$(date +%Y%m%d%H%M%S)
cp -r $work_path $work_path.$datename

# 查找有图片本地路径的文件，拷贝图片到 pic 文件夹下。
infos=`grep -r $src_pic_path --include '*.md' . | tr " " "\?"`
# echo $infos
for info in $infos
do
    echo $info
    # get sub dir
    dir=`echo $info | awk -F ':' '{print $1}'| awk -F '/' '{print $2}'`
    pic_dir=./$dir/pic/
    if [ ! -d $pic_dir ]; then
        mkdir -p $pic_dir
    fi

    # copy
    src_file=`echo $info | awk -F '(' '{print $2}' | awk -F ')' '{print $1}'`
    cp $src_file $pic_dir
    # echo $src_file $pic_dir
    if [ ! $? -eq 0 ]; then
        echo "cp faild $src_file $pic_dir"
    else
        echo "cp success $src_file $pic_dir"
    fi
done

# 替换图片本地路径字符串为相对路径，因为一个文件可能有多个字符串，所以要 uniq
files=`grep -r $src_pic_path --include '*.md' . | tr " " "\?"| awk -F ':' '{print $1}'|uniq`
for file in $files
do
    sed -i '' "s:$src_pic_path:\.\/pic:g" $file
    if [ $? -eq 0 ]; then
        echo "replace success $file"
    fi
done