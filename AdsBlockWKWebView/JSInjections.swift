enum JSInjections {
  
  enum WebViewConfig {
    static let script1 = """
      //Platzhalter
    """
    static let script2 = """
      //Platzhalter
    """
  }
  
  enum WebViewDidCommit {
    static let google = """
      //Platzhalter
    """
  }
  
  enum WebViewDidFinish {
    static let webmail = """
      //Platzhalter
    """
  }
  
  enum UserActions {
    /*static let youtubeClearBuffer = """
      let p = document.getElementById("movie_player"), v = p?.querySelector("video");
      if (!p || !v) throw Error("YouTube player not found");
      let tracks = [...(v.audioTracks || []), ...(v.videoTracks || [])], buffers = [...new Set(tracks.map(q => q.sourceBuffer).filter(Boolean))];
      if (!buffers.length) throw Error("No ManagedSourceBuffer found");
      for (let i = 0; i < buffers.length; i++) {
        let s = buffers[i];
        if (s.updating) await new Promise((r, j) => {
          s.addEventListener("updateend", r, { once: true });
          s.addEventListener("error", () => j(Error("updateend error")), { once: true });
        });
        let ranges = Array.from({ length: s.buffered.length }, (_, n) => [s.buffered.start(n), s.buffered.end(n)]);
        for (let n = ranges.length - 1; n >= 0; n--) {
          let done = new Promise((r, j) => {
            s.addEventListener("updateend", r, { once: true });
            s.addEventListener("error", () => j(Error("remove error")), { once: true });
          });
          s.remove(...ranges[n]);
          await done;
        }
      }
    """*/
    /*static let youtubeClearBuffer = """
      let p = document.getElementById("movie_player"), v = p?.querySelector("video");
      if (!p || !v) throw Error("YouTube player not found");
      let currentTime = v.currentTime, cutoff = currentTime - 2;
      if (!Number.isFinite(cutoff) || cutoff <= 0) throw Error("Playback position too close to the beginning");
      let tracks = [...(v.audioTracks || []), ...(v.videoTracks || [])], buffers = [...new Set(tracks.map(q => q.sourceBuffer).filter(Boolean))];
      if (!buffers.length) throw Error("No ManagedSourceBuffer found");
      for (let s of buffers) {
        if (s.updating) await new Promise((r, j) => {
          s.addEventListener("updateend", r, { once: true });
          s.addEventListener("error", () => j(Error("updateend error")), { once: true });
        });
        let ranges = Array.from({ length: s.buffered.length }, (_, n) => [s.buffered.start(n), s.buffered.end(n)]);
        for (let n = ranges.length - 1; n >= 0; n--) {
          let [start, end] = ranges[n], removeEnd = Math.min(end, cutoff);
          if (start >= removeEnd) continue;
          let done = new Promise((r, j) => {
            s.addEventListener("updateend", r, { once: true });
            s.addEventListener("error", () => j(Error("remove error")), { once: true });
          });
          s.remove(start, removeEnd);
          await done;
        }
      }
    """*/
    static let youtubeClearBuffer = """
      let p = document.getElementById("movie_player"), v = p?.querySelector("video");
      if (!p || !v) throw Error("YouTube player not found");
      if (!Number.isFinite(v.currentTime)) throw Error("Invalid playback position");
      if (v.currentTime <= 2) {
        if (v.paused) p.playVideo();
        let start = Date.now();
        while (v.currentTime <= 2) {
          if (Date.now() - start >= 15000) throw Error("Playback did not reach 2 seconds within 15 seconds");
          await new Promise(r => setTimeout(r, 100));
        }
      }
      let cutoff = v.currentTime - 2;
      let tracks = [...(v.audioTracks || []), ...(v.videoTracks || [])], buffers = [...new Set(tracks.map(q => q.sourceBuffer).filter(Boolean))];
      if (!buffers.length) throw Error("No ManagedSourceBuffer found");
      for (let s of buffers) {
        if (s.updating) await new Promise((r, j) => {
          s.addEventListener("updateend", r, { once: true });
          s.addEventListener("error", () => j(Error("updateend error")), { once: true });
        });
        let ranges = Array.from({ length: s.buffered.length }, (_, n) => [s.buffered.start(n), s.buffered.end(n)]);
        for (let n = ranges.length - 1; n >= 0; n--) {
          let [start, end] = ranges[n], removeEnd = Math.min(end, cutoff);
          if (start >= removeEnd) continue;
          let done = new Promise((r, j) => {
            s.addEventListener("updateend", r, { once: true });
            s.addEventListener("error", () => j(Error("remove error")), { once: true });
          });
          s.remove(start, removeEnd);
          await done;
        }
      }
    """
    static let youtubeCaptureStream = """
      let originalFetch = window.fetch, X = XMLHttpRequest.prototype, originalOpen = X.open, originalSend = X.send;
      try {
        let U = x => x instanceof Uint8Array ? x : new Uint8Array(x),
          V = (a, p) => {
            let n = 0, s = 0, b;
            do {
              b = a[p++];
              n += (b & 127) * 2 ** s;
              s += 7;
            } while (b & 128);
            return { v: n, p };
          },
          E = n => {
            let a = [];
            do {
              let b = n % 128;
              n = Math.floor(n / 128);
              a.push(b | (n ? 128 : 0));
            } while (n);
            return a;
          },
          P = a => {
            let r = [], p = 0;
            while (p < a.length) {
              let st = p, k = V(a, p);
              p = k.p;
              let f = Math.floor(k.v / 8), w = k.v & 7, ps = p;
              if (w === 0) p = V(a, p).p;
              else if (w === 1) p += 8;
              else if (w === 2) {
                let z = V(a, p);
                p = z.p;
                ps = p;
                p += z.v;
              } else if (w === 5) p += 4;
              else throw Error("Wire " + w);
              if (p > a.length) throw Error("Proto overflow");
              r.push({ f, w, st, ps, v: w === 0 ? V(a, ps).v : 0, b: a.slice(ps, p), raw: a.slice(st, p) });
            }
            return r;
          },
          F = (f, w, b) => Uint8Array.from([...E(f * 8 + w), ...(w === 2 ? E(b.length) : []), ...b]),
          N = (f, n) => F(f, 0, Uint8Array.from(E(n))),
          J = (...a) => {
            let o = new Uint8Array(a.reduce((s, x) => s + x.length, 0)), p = 0;
            for (let x of a) {
              o.set(x, p);
              p += x.length;
            }
            return o;
          },
          uv = (a, p) => {
            let b = a[p], n = b >= 240 ? 5 : b >= 224 ? 4 : b >= 192 ? 3 : b >= 128 ? 2 : 1,
              s = n === 5 ? 0 : 8 - n, v = n === 5 ? 0 : b & ((1 << s) - 1);
            for (let i = 1; i < n; i++) {
              v += a[p + i] * 2 ** s;
              s += 8;
            }
            return { v, p: p + n };
          },
          setTime = (b, n) => {
            let a = P(b), r = a.filter(x => x.f !== 28).map(x => x.raw);
            r.push(N(28, n));
            return J(...r);
          };
        let capturedResolve, capturedReject,
          capture = new Promise((r, j) => {
            capturedResolve = r;
            capturedReject = j;
          }),
          captured = false;
        function save(url, method, body, source) {
          if (captured || method !== "POST" || !url || !url.includes("googlevideo.com") || !url.includes("sabr=1") || body == null) return;
          captured = true;
          let task = body instanceof ArrayBuffer ? Promise.resolve(body.slice(0)) :
            ArrayBuffer.isView(body) ? Promise.resolve(body.buffer.slice(body.byteOffset, body.byteOffset + body.byteLength)) :
            typeof body === "string" ? Promise.resolve(new TextEncoder().encode(body).buffer) :
            body instanceof Blob ? body.arrayBuffer() :
            Promise.reject(Error("Unsupported request format"));
          task.then(body => capturedResolve({ url, body })).catch(capturedReject);
        }
        window.fetch = function(input, init) {
          try {
            let url = typeof input === "string" ? input : input.url,
              method = (init?.method || input.method || "GET").toUpperCase();
            if (!captured && method === "POST" && url.includes("googlevideo.com") && url.includes("sabr=1") && input.clone) {
              captured = true;
              input.clone().arrayBuffer().then(body => capturedResolve({ url, body })).catch(capturedReject);
            }
          } catch (e) {}
          return originalFetch.apply(this, arguments);
        };
        X.open = function(method, url) {
          this.__sabrMethod = String(method).toUpperCase();
          this.__sabrUrl = String(url);
          return originalOpen.apply(this, arguments);
        };
        X.send = function(body) {
          try {
            save(this.__sabrUrl, this.__sabrMethod, body, "XMLHttpRequest");
          } catch (e) {}
          return originalSend.apply(this, arguments);
        };
        let player = document.getElementById("movie_player");
        if (!player) throw Error("YouTube player not found");
        
        /*let videoElement = player.querySelector("video");
        videoElement.currentTime = videoElement.currentTime < videoElement.duration - 4 ? videoElement.currentTime + 1 : Math.max(0, videoElement.currentTime - 1);
        await new Promise(r => setTimeout(r, 500));*/
        
        player.seekTo(0, true);
        player.playVideo();
        let fresh;
        try {
          fresh = await Promise.race([
            capture,
            new Promise((_, j) => setTimeout(() => j(Error("No fresh SABR request within 45 seconds. Check whether the video is actually playing.")), 45000))
          ]);
        } finally {
          window.fetch = originalFetch;
          X.open = originalOpen;
          X.send = originalSend;
        }
        let top = P(U(fresh.body)),
          ids = top.filter(x => x.f === 2).map(x => x.b),
          playerResponse = player.getPlayerResponse?.() || window.ytInitialPlayerResponse,
          formats = playerResponse?.streamingData?.adaptiveFormats || [],
          selected = ids.map(descriptor => {
            let itag = P(descriptor).find(x => x.f === 1)?.v,
              format = formats.find(x => x.itag === itag);
            if (!format?.mimeType) throw Error("MIME type for itag " + itag + " not found");
            let type = format.mimeType.startsWith("audio/") ? "audio" :
              format.mimeType.startsWith("video/") ? "video" : "";
            if (!type) throw Error("Unknown stream type for itag " + itag);
            return { descriptor, itag, mimeType: format.mimeType, type };
          });
        if (selected.length !== 2 || selected.filter(x => x.type === "audio").length !== 1 || selected.filter(x => x.type === "video").length !== 1)
          throw Error("SABR request does not contain exactly one audio and one video stream");
        let streams = selected.map(({ itag, mimeType, type }) => ({
            itag, mimeType, type, init: new Uint8Array(), media: new Uint8Array(),
            progress: { lastSeq: 0, downloadedMs: 0, endSegment: 0 }
          })),
          audio = selected.find(x => x.type === "audio").descriptor,
          video = selected.find(x => x.type === "video").descriptor,
          videoStream = streams.find(x => x.type === "video"),
          base = top.filter(x => ![2, 3, 4, 16, 17].includes(x.f)),
          client = base.find(x => x.f === 1 && x.w === 2);
        if (!client) throw Error("ClientAbrState missing");
        let round = {}, requests = [],
          total = Object.fromEntries(streams.map(s => [s.itag, 0]));
        function range(f, r) {
          let tr = J(N(1, r.start), N(2, r.duration), N(3, 1000));
          return J(F(1, 2, f), N(2, r.start), N(3, r.duration), N(4, r.first), N(5, r.last), F(6, 2, tr));
        }
        async function request(first) {
          let tm = videoStream.progress.downloadedMs,
            parts = base.map(x => x.f === 1 && x.w === 2 ? F(1, 2, setTime(x.b, tm)) : x.raw);
          parts.push(N(4, tm), F(16, 2, audio), F(17, 2, video));
          if (!first) {
            for (let s of selected) parts.push(F(2, 2, s.descriptor));
            for (let s of streams)
              if (round[s.itag]) parts.push(F(3, 2, range(selected.find(x => x.itag === s.itag).descriptor, round[s.itag])));
          }
          let res = await originalFetch(fresh.url, { method: "POST", body: J(...parts), credentials: "include" }),
            raw = new Uint8Array(await res.arrayBuffer());
          if (!res.ok) throw Error("HTTP " + res.status);
          let p = 0, H = {}, C = {}, next = {}, types = {},
            added = Object.fromEntries(streams.map(s => [s.itag, []]));
          while (p < raw.length) {
            let t = uv(raw, p);
            p = t.p;
            let l = uv(raw, p);
            p = l.p;
            if (p + l.v > raw.length) throw Error("UMP length error");
            let a = raw.subarray(p, p + l.v);
            p += l.v;
            types[t.v] = (types[t.v] || 0) + 1;
            if (t.v === 20) {
              let q = P(a), g = f => q.find(x => x.f === f),
                h = {
                  id: g(1)?.v || 0, itag: g(3)?.v || 0, init: !!g(8)?.v,
                  seq: g(9)?.v || 0, start: g(11)?.v || 0, duration: g(12)?.v || 0
                },
                tr = g(15);
              if (tr) {
                let z = P(tr.b), v = f => z.find(x => x.f === f)?.v || 0, s = v(3);
                if (s) {
                  if (!h.start) h.start = Math.round(v(1) * 1000 / s);
                  if (!h.duration) h.duration = Math.round(v(2) * 1000 / s);
                }
              }
              H[h.id] = h;
              C[h.id] = [];
            } else if (t.v === 21) {
              let z = uv(a, 0);
              if (C[z.v]) C[z.v].push(a.slice(z.p));
            } else if (t.v === 22) {
              let z = V(a, 0), h = H[z.v];
              if (!h) continue;
              let d = J(...(C[z.v] || [])), stream = streams.find(s => s.itag === h.itag);
              if (!stream) continue;
              if (h.init) {
                stream.init = J(stream.init, d);
              } else if (d.length && h.seq > stream.progress.lastSeq) {
                if (h.seq !== stream.progress.lastSeq + 1)
                  throw Error("Segment gap for itag " + h.itag + ": expected " + (stream.progress.lastSeq + 1) + ", received " + h.seq);
                stream.media = J(stream.media, d);
                stream.progress.lastSeq = h.seq;
                stream.progress.downloadedMs += h.duration;
                total[h.itag] += d.length;
                added[h.itag].push({ seq: h.seq, start: h.start, duration: h.duration, bytes: d.length });
                let r = next[h.itag];
                if (!r) next[h.itag] = r = { start: h.start, duration: 0, first: h.seq, last: h.seq };
                r.duration += h.duration;
                r.last = h.seq;
              }
            } else if (t.v === 42) {
              let q = P(a), f = q.find(x => x.f === 2),
                it = f ? P(f.b).find(x => x.f === 1)?.v : 0,
                stream = streams.find(s => s.itag === it);
              if (stream) stream.progress.endSegment = q.find(x => x.f === 4)?.v || 0;
            } else if (t.v === 46) {
              throw Error("YouTube requires a reload; download aborted");
            }
          }
          round = next;
          requests.push({
            request: requests.length + 1,
            partTypes: types,
            newMedia: added,
            lastSeq: Object.fromEntries(streams.map(s => [s.itag, s.progress.lastSeq])),
            endSegment: Object.fromEntries(streams.map(s => [s.itag, s.progress.endSegment]))
          });
          if (!Object.keys(next).length && !streams.every(s => s.progress.lastSeq >= s.progress.endSegment))
            throw Error("No new segments: " + JSON.stringify(streams.map(s => ({ itag: s.itag, progress: s.progress }))));
        }
        for (let i = 0; i < 40; i++) {
          await request(i === 0);
          if (streams.every(s => s.progress.endSegment && s.progress.lastSeq >= s.progress.endSegment)) break;
        }
        let complete = streams.every(s =>
            s.progress.endSegment &&
            s.progress.lastSeq === s.progress.endSegment &&
            s.init.length > 0 &&
            s.media.length > 0
          ),
          report = {
            complete,
            startedFromZero: true,
            source: "freshly intercepted SABR request",
            requests: requests.length,
            streams: streams.map(s => ({
              itag: s.itag,
              mimeType: s.mimeType,
              type: s.type,
              progress: s.progress,
              initBytes: s.init.length,
              mediaBytes: s.media.length,
              downloadedBytes: total[s.itag]
            })),
            rounds: requests
          };
        window.__sabrStreams = streams;
        window.__sabrRound = round;
        window.__sabrNextRawResponse = null;
        if (!complete) throw Error("Download incomplete: " + JSON.stringify(report));
        return report;
      } catch (e) {
        window.fetch = originalFetch;
        X.open = originalOpen;
        X.send = originalSend;
        throw e;
      }
    """
  }
  
}
