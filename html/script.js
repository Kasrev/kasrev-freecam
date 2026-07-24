const topEl = document.getElementById('top');
const wasdEl = document.getElementById('wasd');

const strings = {
    tr: {
        fare: 'Bakis',
        hiz: 'Hiz +/-',
        ucHiz: '3x Hiz',
        hareket: 'Hareket',
        yukari: 'Yukari / Asagi',
        yatay: 'Yatay Kamera',
        kapat: 'Basili tut > Kapat',
        gizle: 'Gizle',
    },
    en: {
        fare: 'Look',
        hiz: 'Speed +/-',
        ucHiz: '3x Speed',
        hareket: 'Move',
        yukari: 'Up / Down',
        yatay: 'Tilt',
        kapat: 'Hold > Close',
        gizle: 'Hide',
    },
};

let lang = 'tr';

function makeSegment(keys, label) {
    const seg = document.createElement('div');
    seg.className = 'bar-segment';
    const keyWrap = document.createElement('div');
    keyWrap.className = 'bar-keys';
    keys.forEach(k => {
        if (k === '/') {
            const sep = document.createElement('span');
            sep.className = 'sep';
            sep.textContent = '/';
            keyWrap.appendChild(sep);
        } else {
            const el = document.createElement('span');
            el.className = 'bar-kbd';
            el.textContent = k;
            keyWrap.appendChild(el);
        }
    });
    seg.appendChild(keyWrap);
    const lbl = document.createElement('span');
    lbl.className = 'bar-label';
    lbl.textContent = label;
    seg.appendChild(lbl);
    return seg;
}

function makeSep() {
    const el = document.createElement('div');
    el.className = 'bar-sep';
    return el;
}

function buildBars() {
    topEl.innerHTML = '';
    wasdEl.innerHTML = '';

    const s = strings[lang];

    const topRow = document.createElement('div');
    topRow.className = 'top-row';
    topRow.append(
        makeSegment(['Fare'], s.fare),
        makeSep(),
        makeSegment(['Scroll'], s.hiz),
        makeSep(),
        makeSegment(['Shift'], s.ucHiz),
        makeSep(),
        makeSegment(['N'], s.gizle)
    );
    topEl.append(topRow);

    wasdEl.append(
        makeSegment(['W','A','S','D'], s.hareket),
        makeSep(),
        makeSegment(['R','/','F'], s.yukari),
        makeSep(),
        makeSegment(['Q','/','E'], s.yatay),
        makeSep(),
        makeSegment(['V'], s.kapat)
    );
}

buildBars();

const toastEl = document.getElementById('toast');
let toastTimer = null;

function showToast(text) {
    if (toastTimer) clearTimeout(toastTimer);
    toastEl.textContent = text;
    toastEl.classList.add('visible');
    toastTimer = setTimeout(() => {
        toastEl.classList.remove('visible');
        toastTimer = null;
    }, 1500);
}

window.addEventListener('message', function(e) {
    const data = e.data;
    switch (data.type) {
        case 'show':
            if (data.locale && data.locale !== lang) {
                lang = data.locale;
                buildBars();
            }
            topEl.classList.remove('hidden');
            wasdEl.classList.remove('hidden');
            topEl.classList.add('visible');
            wasdEl.classList.add('visible');
            break;
        case 'hide':
            topEl.classList.remove('visible', 'hidden');
            wasdEl.classList.remove('visible', 'hidden');
            break;
        case 'toggle_ui':
            if (topEl.classList.contains('hidden')) {
                topEl.classList.remove('hidden');
                wasdEl.classList.remove('hidden');
            } else {
                topEl.classList.add('hidden');
                wasdEl.classList.add('hidden');
            }
            break;
        case 'toast':
            showToast(data.text);
            break;
    }
});
