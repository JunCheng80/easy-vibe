<template>
  <div class="rt-wrap" :class="`rt-${size}`" aria-live="polite">
    <span class="rt-text">{{ shown }}</span>
    <span v-if="cursor" class="rt-caret">|</span>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'

const props = defineProps({
  items: { type: Array, default: () => [] },

  // 打字速度/回删速度（毫秒）
  typeSpeed: { type: Number, default: 45 },
  deleteSpeed: { type: Number, default: 22 },

  // 停顿：打完后停多久、删完后停多久
  holdAfterType: { type: Number, default: 1200 },
  holdAfterDelete: { type: Number, default: 250 },

  cursor: { type: Boolean, default: true },

  // 视觉：字号和上下间距（更像首页 tagline）
  size: { type: String, default: 'small' }, // 'small' | 'normal'
  blockMargin: { type: String, default: '10px' } // 段前后间距
})

const list = computed(() => (props.items || []).filter(Boolean))
const idx = ref(0)
const shown = ref('')
const phase = ref('typing') // typing | holding | deleting
let timer = null

function clear() {
  if (timer) clearTimeout(timer)
  timer = null
}

function nextTick() {
  clear()
  if (!list.value.length) return

  const full = String(list.value[idx.value] ?? '')
  const cur = shown.value

  if (phase.value === 'typing') {
    if (cur.length < full.length) {
      shown.value = full.slice(0, cur.length + 1)
      timer = setTimeout(nextTick, props.typeSpeed)
    } else {
      phase.value = 'holding'
      timer = setTimeout(nextTick, props.holdAfterType)
    }
    return
  }

  if (phase.value === 'holding') {
    phase.value = 'deleting'
    timer = setTimeout(nextTick, props.deleteSpeed)
    return
  }

  // deleting
  if (cur.length > 0) {
    shown.value = cur.slice(0, -1)
    timer = setTimeout(nextTick, props.deleteSpeed)
  } else {
    phase.value = 'typing'
    idx.value = (idx.value + 1) % list.value.length
    timer = setTimeout(nextTick, props.holdAfterDelete)
  }
}

onMounted(() => {
  // 初始立刻开始
  shown.value = ''
  phase.value = 'typing'
  idx.value = 0
  nextTick()
})

onUnmounted(() => clear())

// items 改了就重启（你改文案时不会卡住）
watch(
  () => props.items,
  () => {
    idx.value = 0
    shown.value = ''
    phase.value = 'typing'
    nextTick()
  }
)
</script>

<style scoped>
/* ✅ 1) 段前后间距：像首页 tagline 那样“夹在标题与按钮之间” */
.rt-wrap{
  margin: 12px 0 18px;          /* ✅ 段前后间距 */
  min-height: 22px;             /* ✅ 防止抖动：每条长度不同高度跳 */
  display: flex;
  align-items: center;
  gap: 2px;
  color: var(--vp-c-text-2);    /* ✅ 更柔和的灰 */
  /*  font-size: 17px;              ✅ 比正文略小，像广告条 */
  line-height: 1.6;
}

.rt-small{ font-size: 14px; }
.rt-normal{ font-size: 16px; } 
.rt-large{ font-size: 18px; } /* 想更大就 198 */

.rt-text{
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.rt-caret{
  color: var(--vp-c-text-3);    /* ✅ 光标更淡 */
  animation: rt-blink 1s step-end infinite;
}

@keyframes rt-blink {
  50% { opacity: 0; }
}

</style>
