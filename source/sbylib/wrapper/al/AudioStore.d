/**
 * Autors: @nari
 */

module sbylib.wrapper.al.AudioStore;

import derelict.openal.al;
import derelict.alure.alure;
import std.stdio, std.string;
import sbylib.setting;

// AudioStore クラス
// オーディオリソースを保持、適宜再生などをします

// ALURE とかいう神をつかってリソースのロードは filename から行います
// audioBufMap にすべてのリソースの bufferID をまとめます

// filename か bufID を受け取って再生する機能を作ります
// bgmSrcList にはそのうち意図的に「止める」という操作が必要なものをまとめておきます
// seSrcMap には↑以外のものをまとめておきます

// bgm/se それぞれ独立に「止める機能」「音量を変える機能」を作ります
// 音量調整や、ポーズ画面で BGM だけ流しつつ SE を止める、みたいな使われ方を想定しています

// ここに書くのもあれだけど、リソースの読み込みで毎回 SbyWorld.rootPath 呼ぶのはだるい
// ロード関数内でくっつけるような処理を書く
// リソースロードしているのは以下のとおり

// 画像
// 音楽(ここ)
// フォント
// モデル

// とりあえずそれは本流で直接やることにして、このブランチでは音楽の実装を優先させます

class AudioStore {
    // audioBufMap[filePath] := filePath の音源のバッファID
    static uint[string] audioBufMap;
    // audioLen[bufID] := bufID バッファの音声の長さ(秒)
    static float[uint] audioLen;

    // TODO: この3つはまとめて構造体にしたほうがアクセス効率的なアレで良さそう
    // bgmSrcList[bufID] := bufID バッファをソースにしたもの ( 1 BGM 1 ソース )
    static uint[uint] bgmSrcList;
    // bgmLoopFromPos[bufID] := bufID バッファの BGM のループ位置
    static float[uint] bgmLoopFromPos;
    // bgmLoopToPos[bufID] := bufID バッファの BGM のループ位置 (From < To)
    static float[uint] bgmLoopToPos;
    // isBgmLoop[bufID] := bufID バッファの BGM をループ再生しているかどうか
    static bool[uint] isBgmLoop;

    // sePlayList[srcID] := srcID のソースのバッファID (再生位置管理のために必要)
    static uint[uint] sePlayList;

    static void init(){
        assert(alureInitDevice(null, null), "Failed to init alure!");
    }

    /** ファイルからバッファへのロード
   * Params:
   * filePath = 読み込む音声ファイルのパス
   */
    static uint load(string filePath){
        if( (filePath in audioBufMap) !is null ){
            return audioBufMap[filePath];
        }
        uint buf = alureCreateBufferFromFile(cast(char*)filePath.toStringz);
        if (buf == AL_NONE) {
            assert(false, "Failed to load from file!");
        }
        audioBufMap[filePath] = buf;

        int size, freq, channel, bits;
        alGetBufferi(buf, AL_SIZE, &size);
        alGetBufferi(buf, AL_FREQUENCY, &freq);
        alGetBufferi(buf, AL_CHANNELS, &channel);
        alGetBufferi(buf, AL_BITS, &bits);
        audioLen[buf] = cast(float)(size*8)/cast(float)(freq*channel*bits);

        return buf;
    }

    // バッファからソースを生成
    static uint loadSrcFromBuf(uint bufID){
        uint src;
        alGenSources(1,&src);
        alSourcei(src,AL_BUFFER,bufID);
        return src;
    }

    // BGM として再生
    static void playBGM(uint bufID, bool isLoop = false){
        uint src;
        if( (bufID in bgmSrcList) is null ){
            src = loadSrcFromBuf(bufID);
            bgmSrcList[bufID] = src;
        }else{
            src = bgmSrcList[bufID];
        }
        // TODO: 再生中ならダメだし、ループチェックも
        if( (bufID in bgmLoopFromPos) is null ){
            bgmLoopFromPos[bufID] = 0;
            bgmLoopToPos[bufID] = audioLen[bufID];
        }
        isBgmLoop[bufID] = isLoop;
        // 再生
        alSourcePlay(src);
    }

    static void playBGM(string filePath, bool isLoop = false){
        if( (filePath in audioBufMap) is null ){
            writeln("[AudioStore]使用する前にロードされていませんでした : "~filePath);
            load(filePath);
        }
        playBGM(audioBufMap[filePath], isLoop);
    }

    // ループの設定
    // [from,to] の範囲をループするようになる(単位は秒)
    static void setLoopPos(uint bufID, float from, float to){
        bgmLoopFromPos[bufID] = from;
        bgmLoopToPos[bufID] = to;
    }
    static void setLoopPos(string filePath, float from, float to){
        if( (filePath in audioBufMap) is null ){
            writeln("[AudioStore]使用する前にロードされていませんでした : "~filePath);
            load(filePath);
        }
        setLoopPos(audioBufMap[filePath],from,to);
    }

    // SE として再生
    static void playSE(uint bufID){
        uint src = loadSrcFromBuf(bufID);

        alSourcePlay(src);
        sePlayList[src] = bufID;
    }
    static void playSE(string filePath){
        if( (filePath in audioBufMap) is null ){
            writeln("[AudioStore]使用する前にロードされていませんでした : "~filePath);
            load(filePath);
        }
        playSE(audioBufMap[filePath]);
    }

    // 毎フレーム呼ぶ奴
    // 再生中はそのまま
    // 再生終了してたら BGM ならループ、 SE ならソースの除去
    static void update(){
        // BGM リストを見ていく
        foreach(uint buf, uint src ; bgmSrcList){
            int state;
            alGetSourcei(src, AL_SOURCE_STATE, &state);
            if(state == AL_STOPPED || state == AL_INITIAL || state == AL_PAUSED) continue;
            float offset;
            alGetSourcef(src, AL_SEC_OFFSET, &offset);
            if(offset >= bgmLoopToPos[buf]){
                // rewind
                int size;
                alGetSourcei(src, AL_SIZE, &size);
                alSourcef(src, AL_SEC_OFFSET, bgmLoopFromPos[buf]);
            }
        }

        // SE リストを見ていく
        foreach(uint src ; sePlayList.keys){
            int state;
            alGetSourcei(src, AL_SOURCE_STATE, &state);
            if(state == AL_STOPPED){
                alDeleteSources(1, &src);
                sePlayList.remove(src);
            }
        }
    }
}
