let audioContext = null

function initAudio() {
  try {
    audioContext = new (window.AudioContext || window.webkitAudioContext)()
  } catch (e) {
    console.error("Web Audio API is not supported in this browser", e)
  }
}

function playClickSound() {
  if (!audioContext) return

  const oscillator = audioContext.createOscillator()
  const gainNode = audioContext.createGain()

  oscillator.type = "sine"
  oscillator.frequency.setValueAtTime(800, audioContext.currentTime)
  oscillator.frequency.exponentialRampToValueAtTime(500, audioContext.currentTime + 0.1)

  gainNode.gain.setValueAtTime(0.2, audioContext.currentTime)
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1)

  oscillator.connect(gainNode)
  gainNode.connect(audioContext.destination)

  oscillator.start()
  oscillator.stop(audioContext.currentTime + 0.1)
}

function playTypeSound() {
  if (!audioContext) return

  const oscillator = audioContext.createOscillator()
  const gainNode = audioContext.createGain()

  oscillator.type = "sine"
  oscillator.frequency.setValueAtTime(1200, audioContext.currentTime)

  gainNode.gain.setValueAtTime(0.05, audioContext.currentTime)
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.05)

  oscillator.connect(gainNode)
  gainNode.connect(audioContext.destination)

  oscillator.start()
  oscillator.stop(audioContext.currentTime + 0.05)
}

function playCheckSound() {
  if (!audioContext) return

  const oscillator = audioContext.createOscillator()
  const gainNode = audioContext.createGain()

  oscillator.type = "square"
  oscillator.frequency.setValueAtTime(600, audioContext.currentTime)
  oscillator.frequency.exponentialRampToValueAtTime(900, audioContext.currentTime + 0.1)

  gainNode.gain.setValueAtTime(0.15, audioContext.currentTime)
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1)

  oscillator.connect(gainNode)
  gainNode.connect(audioContext.destination)

  oscillator.start()
  oscillator.stop(audioContext.currentTime + 0.1)
}

function playEnterUISound() {
  if (!audioContext) return

  const oscillator = audioContext.createOscillator()
  const gainNode = audioContext.createGain()

  oscillator.type = "sine"
  oscillator.frequency.setValueAtTime(400, audioContext.currentTime)
  oscillator.frequency.exponentialRampToValueAtTime(800, audioContext.currentTime + 0.2)

  gainNode.gain.setValueAtTime(0.2, audioContext.currentTime)
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2)

  oscillator.connect(gainNode)
  gainNode.connect(audioContext.destination)

  oscillator.start()
  oscillator.stop(audioContext.currentTime + 0.2)
}

function playExitUISound() {
  if (!audioContext) return

  const oscillator = audioContext.createOscillator()
  const gainNode = audioContext.createGain()

  oscillator.type = "sine"
  oscillator.frequency.setValueAtTime(800, audioContext.currentTime)
  oscillator.frequency.exponentialRampToValueAtTime(400, audioContext.currentTime + 0.2)

  gainNode.gain.setValueAtTime(0.2, audioContext.currentTime)
  gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2)

  oscillator.connect(gainNode)
  gainNode.connect(audioContext.destination)

  oscillator.start()
  oscillator.stop(audioContext.currentTime + 0.2)
}

function isEditMode() {
  const stashIdInput = document.getElementById("stash-id")
  return stashIdInput && stashIdInput.readOnly === true
}

function resetEditMode() {
  const stashIdInput = document.getElementById("stash-id")
  if (!stashIdInput) return

  stashIdInput.readOnly = false
  stashIdInput.style.opacity = "1"
  stashIdInput.style.cursor = "text"

  const createBtn = document.getElementById("create-btn")
  if (createBtn) createBtn.textContent = "CREATE STASH"

  if (stashIdInput) stashIdInput.value = ""

  const labelInput = document.getElementById("stash-label")
  if (labelInput) labelInput.value = ""

  const slotsInput = document.getElementById("stash-slots")
  if (slotsInput) slotsInput.value = "30"

  const weightInput = document.getElementById("stash-weight")
  if (weightInput) weightInput.value = "100000"

  const personalCheckbox = document.getElementById("stash-personal")
  if (personalCheckbox) personalCheckbox.checked = false

  const citizenIdInput = document.getElementById("stash-citizen-id")
  if (citizenIdInput) citizenIdInput.value = ""

  const jobsInput = document.getElementById("stash-jobs")
  if (jobsInput) {
    jobsInput.value = ""
    jobsInput.disabled = false
  }

  zoneData = {
    width: 1.0,
    length: 1.0,
    height: 1.0,
    coords: null,
    rotation: 0,
    frozen: false,
  }

  if (typeof updateZoneDisplay === "function") {
    updateZoneDisplay()
  }
}

let zoneData = {
  width: 1.0,
  length: 1.0,
  height: 1.0,
  coords: null,
  rotation: 0,
  frozen: false,
}

let currentStashDetails = null
let allStashes = []
const actionDebounce = false

function GetParentResourceName() {
  return "aura-stashes"
}

document.addEventListener("DOMContentLoaded", () => {
  const personalCheckbox = document.getElementById("stash-personal")
  const citizenIdContainer = document.getElementById("citizen-id-container")
  const jobsInput = document.getElementById("stash-jobs")
  const slotsInput = document.getElementById("stash-slots")
  const weightInput = document.getElementById("stash-weight")

  initAudio()

  let buttonDebounce = false

  citizenIdContainer.style.display = personalCheckbox.checked ? "block" : "none"
  jobsInput.disabled = personalCheckbox.checked

  personalCheckbox.addEventListener("change", function () {
    playCheckSound()
    citizenIdContainer.style.display = this.checked ? "block" : "none"
    jobsInput.disabled = this.checked

    const inventoryType = window.inventoryType || "unknown"
    if (inventoryType === "esx") {
      slotsInput.disabled = this.checked
      weightInput.disabled = this.checked
    }
  })

  document.getElementById("close-btn").addEventListener("click", () => {
    document.getElementById("app").style.display = "none"
    document.getElementById("controls-helper").style.display = "none"
    document.getElementById("dimensions-display").style.display = "none"

    if (typeof isEditMode === "function" && isEditMode()) {
      if (typeof resetEditMode === "function") {
        resetEditMode()
      }
    }

    playExitUISound()

    fetch(`https://${GetParentResourceName()}/closeUI`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    }).catch(() => {
      if ("invokeNative" in window) {
        window.invokeNative("closeApplication")
      }
    })
  })

  document.getElementById("close-list-btn").addEventListener("click", () => {
    playExitUISound()
    document.getElementById("stash-list-container").style.display = "none"

    fetch(`https://${GetParentResourceName()}/closeStashList`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    })
  })

  document.getElementById("close-details-btn").addEventListener("click", () => {
    playExitUISound()
    document.getElementById("stash-details-container").style.display = "none"
    document.getElementById("stash-list-container").style.display = "none"

    fetch(`https://${GetParentResourceName()}/closeStashList`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    })
  })

  document.getElementById("zone-btn").addEventListener("click", () => {
    playClickSound()
    fetch(`https://${GetParentResourceName()}/setZone`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    })
  })

  document.getElementById("create-btn").addEventListener("click", () => {
    if (buttonDebounce) return
    buttonDebounce = true

    playClickSound()
    const stashId = document.getElementById("stash-id").value
    const stashLabel = document.getElementById("stash-label").value
    const stashSlots = document.getElementById("stash-slots").value
    const stashWeight = document.getElementById("stash-weight").value
    const isPersonal = document.getElementById("stash-personal").checked
    const citizenId = document.getElementById("stash-citizen-id").value
    const jobsAccess = document.getElementById("stash-jobs").value

    if (!stashId || !stashLabel) {
      buttonDebounce = false
      return
    }

    const inventoryType = window.inventoryType || "unknown"
    if (inventoryType !== "esx" && (!stashSlots || !stashWeight)) {
      buttonDebounce = false
      return
    }

    if (isPersonal && !citizenId) {
      buttonDebounce = false
      return
    }

    let groups = null
    if (!isPersonal && jobsAccess) {
      groups = {}
      const jobPairs = jobsAccess.split(",")
      for (const pair of jobPairs) {
        const [job, grade] = pair.split(":")
        if (job && grade) {
          groups[job.trim()] = Number.parseInt(grade.trim())
        }
      }
    }

    const stashData = {
      id: stashId,
      label: stashLabel,
      slots: Number.parseInt(stashSlots),
      maxWeight: Number.parseInt(stashWeight),
      owner: isPersonal ? citizenId : false,
      groups: groups,
      coords: zoneData.coords,
      zone: {
        width: zoneData.width,
        length: zoneData.length,
        height: zoneData.height,
        rotation: zoneData.rotation,
      },
    }

    if (isEditMode()) {
      document.getElementById("app").style.display = "none"
      document.getElementById("controls-helper").style.display = "none"
      document.getElementById("dimensions-display").style.display = "none"

      playExitUISound()

      fetch(`https://${GetParentResourceName()}/updateStash`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(stashData),
      })
    } else {
      fetch(`https://${GetParentResourceName()}/createStash`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(stashData),
      })
    }

    setTimeout(() => {
      buttonDebounce = false
    }, 1000)
  })

  document.getElementById("stash-search").addEventListener("input", function () {
    const searchTerm = this.value.toLowerCase()
    filterStashes(searchTerm)
  })

  document.getElementById("edit-stash-btn").addEventListener("click", () => {
    playClickSound()
    if (currentStashDetails) {
      document.getElementById("stash-details-container").style.display = "none"
      document.getElementById("app").style.display = "flex"

      const stash = currentStashDetails
      const stashIdInput = document.getElementById("stash-id")

      stashIdInput.value = stash.id || ""
      document.getElementById("stash-label").value = stash.label || ""
      document.getElementById("stash-slots").value = stash.slots || 30
      document.getElementById("stash-weight").value = stash.maxWeight || 100000

      stashIdInput.readOnly = true
      stashIdInput.style.opacity = "0.7"
      stashIdInput.style.cursor = "not-allowed"

      document.getElementById("create-btn").textContent = "UPDATE STASH"

      const isPersonal = typeof stash.owner === "string" && stash.owner !== ""
      document.getElementById("stash-personal").checked = isPersonal

      citizenIdContainer.style.display = isPersonal ? "block" : "none"

      if (isPersonal) {
        document.getElementById("stash-citizen-id").value = stash.owner
      }

      document.getElementById("stash-jobs").disabled = isPersonal

      if (stash.groups) {
        let jobsString = ""
        for (const [job, grade] of Object.entries(stash.groups)) {
          jobsString += `${job}:${grade},`
        }
        document.getElementById("stash-jobs").value = jobsString.slice(0, -1)
      }

      if (stash.zone) {
        zoneData = {
          width: stash.zone.width || 1.0,
          length: stash.zone.length || 1.0,
          height: stash.zone.height || 1.0,
          rotation: stash.zone.rotation || 0,
          coords: stash.coords,
          frozen: false,
        }

        updateZoneDisplay()
      }
    }
  })

  document.getElementById("delete-stash-btn").addEventListener("click", () => {
    if (buttonDebounce) return
    buttonDebounce = true

    playClickSound()
    if (currentStashDetails) {
      showConfirmationDialog(
        "Delete Stash",
        `Are you sure you want to delete the stash "${currentStashDetails.label}"? This action cannot be undone.`,
        () => {
          fetch(`https://${GetParentResourceName()}/deleteStash`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ id: currentStashDetails.id }),
          })

          document.getElementById("stash-details-container").style.display = "none"
          document.getElementById("stash-list-container").style.display = "flex"

          const index = allStashes.findIndex((stash) => stash.id === currentStashDetails.id)
          if (index !== -1) {
            allStashes.splice(index, 1)
            renderStashList(allStashes)
          }
        },
      )
    }

    setTimeout(() => {
      buttonDebounce = false
    }, 1000)
  })

  document.getElementById("teleport-stash-btn").addEventListener("click", () => {
    if (buttonDebounce) return
    buttonDebounce = true

    playClickSound()
    if (currentStashDetails && currentStashDetails.coords) {
      fetch(`https://${GetParentResourceName()}/teleportToStash`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ coords: currentStashDetails.coords }),
      })

      document.getElementById("stash-details-container").style.display = "none"
    }

    setTimeout(() => {
      buttonDebounce = false
    }, 1000)
  })

  const controlsHelper = document.createElement("div")
  controlsHelper.id = "controls-helper"
  controlsHelper.className = "controls-helper"
  controlsHelper.innerHTML = `
      <div class="controls-title">CONTROLS</div>
      <div class="control-item">
          <div class="key">↑/↓</div>
          <div class="action">Adjust Height</div>
      </div>
      <div class="control-item">
          <div class="key">←/→</div>
          <div class="action">Adjust Width</div>
      </div>
      <div class="control-item">
          <div class="key">Z/X</div>
          <div class="action">Adjust Length</div>
      </div>
      <div class="control-item">
          <div class="key">Mouse Wheel</div>
          <div class="action">Rotate Box</div>
      </div>
      <div class="control-item">
          <div class="key">Left Click</div>
          <div class="action">Freeze/Unfreeze</div>
      </div>
      <div class="control-item">
          <div class="key">Enter</div>
          <div class="action">Confirm</div>
      </div>
      <div class="control-item">
          <div class="key">Esc</div>
          <div class="action">Cancel</div>
      </div>
  `
  document.body.appendChild(controlsHelper)
  controlsHelper.style.display = "none"

  const dimensionsDisplay = document.createElement("div")
  dimensionsDisplay.id = "dimensions-display"
  dimensionsDisplay.className = "dimensions-display"
  dimensionsDisplay.innerHTML = `
    <div class="dimensions-title">BOX DIMENSIONS</div>
    <div class="dimensions-grid">
        <div class="dimension-item">
            <div class="dimension-label">W</div>
            <div class="dimension-value" id="dim-width">1.0</div>
        </div>
        <div class="dimension-item">
            <div class="dimension-label">L</div>
            <div class="dimension-value" id="dim-length">1.0</div>
        </div>
        <div class="dimension-item">
            <div class="dimension-label">H</div>
            <div class="dimension-value" id="dim-height">1.0</div>
        </div>
        <div class="dimension-item">
            <div class="dimension-label">R</div>
            <div class="dimension-value" id="dim-rotation">0°</div>
        </div>
    </div>
    <div class="coordinates">
        <div class="dimension-label">Position</div>
        <div class="dimension-value" id="dim-coords">X: 0.00 Y: 0.00 Z: 0.00</div>
    </div>
    <div class="status-indicator">
        <div class="dimension-value" id="dim-status">Moving</div>
    </div>
`
  document.body.appendChild(dimensionsDisplay)
  dimensionsDisplay.style.display = "none"

  window.addEventListener("message", (event) => {
    const data = event.data

    if (data.type === "showUI") {
      document.getElementById("app").style.display = "flex"
      document.getElementById("controls-helper").style.display = "none"
      document.getElementById("dimensions-display").style.display = "none"
      document.getElementById("stash-list-container").style.display = "none"
      document.getElementById("stash-details-container").style.display = "none"

      initAudio()
      playEnterUISound()

      window.inventoryType = data.inventoryType || "unknown"

      if (data.inventoryType === "esx") {
        if (personalCheckbox.checked) {
          slotsInput.disabled = true
          weightInput.disabled = true
        }
      }

      if (data.stashData) {
        const stash = data.stashData
        const stashIdInput = document.getElementById("stash-id")

        stashIdInput.value = stash.id || ""
        document.getElementById("stash-label").value = stash.label || ""
        document.getElementById("stash-slots").value = stash.slots || 30
        document.getElementById("stash-weight").value = stash.maxWeight || 100000

        const isEditing = stash.id && stash.id !== ""
        if (isEditing) {
          stashIdInput.readOnly = true
          stashIdInput.style.opacity = "0.7"
          stashIdInput.style.cursor = "not-allowed"

          document.getElementById("create-btn").textContent = "UPDATE STASH"
        } else {
          stashIdInput.readOnly = false
          stashIdInput.style.opacity = "1"
          stashIdInput.style.cursor = "text"

          document.getElementById("create-btn").textContent = "CREATE STASH"
        }

        const isPersonal = typeof stash.owner === "string" && stash.owner !== ""
        document.getElementById("stash-personal").checked = isPersonal

        citizenIdContainer.style.display = isPersonal ? "block" : "none"

        if (isPersonal) {
          document.getElementById("stash-citizen-id").value = stash.owner
        }

        document.getElementById("stash-jobs").disabled = isPersonal

        if (stash.groups) {
          let jobsString = ""
          for (const [job, grade] of Object.entries(stash.groups)) {
            jobsString += `${job}:${grade},`
          }
          document.getElementById("stash-jobs").value = jobsString.slice(0, -1)
        }

        if (stash.zone) {
          zoneData = {
            width: stash.zone.width || 1.0,
            length: stash.zone.length || 1.0,
            height: stash.zone.height || 1.0,
            rotation: stash.zone.rotation || 0,
            coords: stash.coords,
            frozen: false,
          }

          updateZoneDisplay()
        }
      }
    } else if (data.type === "hideUI") {
      if (data.forceHide) {
        document.getElementById("app").style.display = "none"
        document.getElementById("stash-list-container").style.display = "none"
        document.getElementById("stash-details-container").style.display = "none"
        document.getElementById("controls-helper").style.display = "none"
        document.getElementById("dimensions-display").style.display = "none"

        if (typeof isEditMode === "function" && isEditMode()) {
          if (typeof resetEditMode === "function") {
            resetEditMode()
          }
        }

        playExitUISound()
      } else {
        document.getElementById("app").style.display = "none"
        document.getElementById("stash-list-container").style.display = "none"
        document.getElementById("stash-details-container").style.display = "none"
      }

      if (!data.showControls && !data.showDimensions) {
        playExitUISound()
      }

      if (data.showControls) {
        document.getElementById("controls-helper").style.display = "block"
      } else {
        document.getElementById("controls-helper").style.display = "none"
      }

      if (data.showDimensions) {
        document.getElementById("dimensions-display").style.display = "block"
      } else {
        document.getElementById("dimensions-display").style.display = "none"
      }
    } else if (data.type === "updateZone") {
      zoneData = data.zoneData || {}
      updateZoneDisplay()

      if (data.showControls === false) {
        document.getElementById("controls-helper").style.display = "none"
      }

      if (data.showDimensions === false) {
        document.getElementById("dimensions-display").style.display = "none"
      }

      if (data.zoneData && data.zoneData.coords) {
        console.log("Received coordinates:", data.zoneData.coords)
      }
    } else if (data.type === "updateDimensions") {
      zoneData = data.zoneData
      updateDimensionsDisplay()
    } else if (data.type === "setInventoryType") {
      window.inventoryType = data.inventoryType

      if (data.inventoryType === "esx") {
        if (personalCheckbox.checked) {
          slotsInput.disabled = true
          weightInput.disabled = true
        }
      } else {
        slotsInput.disabled = false
        weightInput.disabled = false
      }
    } else if (data.type === "showStashList") {
      document.getElementById("app").style.display = "none"
      document.getElementById("stash-list-container").style.display = "flex"
      document.getElementById("stash-details-container").style.display = "none"

      initAudio()
      playEnterUISound()

      allStashes = data.stashes || []

      renderStashList(allStashes)
    }
  })

  function updateZoneDisplay() {
    const zoneInfo = document.querySelector(".zone-info")

    let zoneHtml = `
    <div class="zone-item">
        <span>Width:</span>
        <span id="zone-width">${zoneData.width.toFixed(1)}</span>
    </div>
    <div class="zone-item">
        <span>Length:</span>
        <span id="zone-length">${zoneData.length.toFixed(1)}</span>
    </div>
    <div class="zone-item">
        <span>Height:</span>
        <span id="zone-height">${zoneData.height.toFixed(1)}</span>
    </div>
    <div class="zone-item">
        <span>Rotation:</span>
        <span id="zone-rotation">${zoneData.rotation || 0}°</span>
    </div>
  `

    if (zoneData.coords) {
      zoneHtml += `
      <div class="zone-item">
          <span>X:</span>
          <span>${zoneData.coords.x.toFixed(2)}</span>
      </div>
      <div class="zone-item">
          <span>Y:</span>
          <span>${zoneData.coords.y.toFixed(2)}</span>
      </div>
      <div class="zone-item">
          <span>Z:</span>
          <span>${zoneData.coords.z.toFixed(2)}</span>
      </div>
    `
    } else {
      zoneHtml += `
      <div class="zone-item">
          <span>X:</span>
          <span>0.00</span>
      </div>
      <div class="zone-item">
          <span>Y:</span>
          <span>0.00</span>
      </div>
      <div class="zone-item">
          <span>Z:</span>
          <span>0.00</span>
      </div>
    `
    }

    zoneInfo.innerHTML = zoneHtml

    updateDimensionsDisplay()
  }

  function updateDimensionsDisplay() {
    document.getElementById("dim-width").textContent = zoneData.width.toFixed(1)
    document.getElementById("dim-length").textContent = zoneData.length.toFixed(1)
    document.getElementById("dim-height").textContent = zoneData.height.toFixed(1)
    document.getElementById("dim-rotation").textContent = `${zoneData.rotation || 0}°`

    if (zoneData.coords) {
      document.getElementById("dim-coords").textContent =
        `X: ${zoneData.coords.x.toFixed(2)} Y: ${zoneData.coords.y.toFixed(2)} Z: ${zoneData.coords.z.toFixed(2)}`
    }

    const statusElement = document.getElementById("dim-status")
    if (zoneData.frozen) {
      statusElement.textContent = "Frozen"
      statusElement.className = "dimension-value frozen"
    } else {
      statusElement.textContent = "Moving"
      statusElement.className = "dimension-value moving"
    }
  }

  function renderStashList(stashes) {
    const stashListItems = document.getElementById("stash-list-items")
    stashListItems.innerHTML = ""

    if (stashes.length === 0) {
      stashListItems.innerHTML = `<div class="no-stashes">No stashes found</div>`
      return
    }

    stashes.forEach((stash) => {
      const stashItem = document.createElement("div")
      stashItem.className = "stash-item"
      stashItem.innerHTML = `
        <div class="stash-info">
          <div class="stash-name">${stash.label}</div>
          <div class="stash-id">ID: ${stash.id}</div>
        </div>
        <div class="stash-actions">
          <div class="stash-action view-stash" data-id="${stash.id}">
            <i class="fas fa-eye"></i>
          </div>
        </div>
      `

      stashListItems.appendChild(stashItem)

      stashItem.querySelector(".view-stash").addEventListener("click", function () {
        playClickSound()
        const stashId = this.getAttribute("data-id")
        const stashDetails = stashes.find((s) => s.id === stashId)
        if (stashDetails) {
          showStashDetails(stashDetails)
        }
      })
    })
  }

  function filterStashes(searchTerm) {
    const filteredStashes = allStashes.filter(
      (stash) => stash.label.toLowerCase().includes(searchTerm) || stash.id.toLowerCase().includes(searchTerm),
    )
    renderStashList(filteredStashes)
  }

  function showStashDetails(stash) {
    currentStashDetails = stash

    document.getElementById("stash-list-container").style.display = "none"
    document.getElementById("stash-details-container").style.display = "flex"

    document.querySelector("#stash-details .title").textContent = `STASH DETAILS: ${stash.label}`

    const detailsGrid = document.getElementById("details-grid")
    detailsGrid.innerHTML = ""

    let ownerText = "Public"
    if (stash.owner && typeof stash.owner === "string") {
      ownerText = `Personal (Owner: ${stash.owner})`
    } else if (stash.owner === true) {
      ownerText = "Personal (Any Owner)"
    }

    let groupsText = "None"
    if (stash.groups && Object.keys(stash.groups).length > 0) {
      groupsText = ""
      for (const [job, grade] of Object.entries(stash.groups)) {
        groupsText += `${job}:${grade}, `
      }
      groupsText = groupsText.slice(0, -2)
    }

    let coordsText = "Unknown"
    if (stash.coords) {
      coordsText = `X: ${stash.coords.x.toFixed(2)}, Y: ${stash.coords.y.toFixed(2)}, Z: ${stash.coords.z.toFixed(2)}`
    }

    let zoneText = "Default"
    if (stash.zone) {
      zoneText = `W: ${stash.zone.width.toFixed(1)}, L: ${stash.zone.length.toFixed(1)}, H: ${stash.zone.height.toFixed(1)}, R: ${stash.zone.rotation || 0}°`
    }

    addDetailItem(detailsGrid, "ID", stash.id)
    addDetailItem(detailsGrid, "Label", stash.label)
    addDetailItem(detailsGrid, "Slots", stash.slots)
    addDetailItem(detailsGrid, "Max Weight", `${stash.maxWeight}g`)
    addDetailItem(detailsGrid, "Owner Type", ownerText)
    addDetailItem(detailsGrid, "Job Access", groupsText)
    addDetailItem(detailsGrid, "Location", coordsText, true)
    addDetailItem(detailsGrid, "Zone Dimensions", zoneText, true)
  }

  function addDetailItem(grid, label, value, fullWidth = false) {
    const detailItem = document.createElement("div")
    detailItem.className = `detail-item ${fullWidth ? "full-width" : ""}`
    detailItem.innerHTML = `
      <div class="detail-label">${label}</div>
      <div class="detail-value">${value}</div>
    `
    grid.appendChild(detailItem)
  }

  function showConfirmationDialog(title, message, onConfirm) {
    const dialog = document.createElement("div")
    dialog.className = "confirmation-dialog"
    dialog.innerHTML = `
      <div class="confirmation-content">
        <div class="confirmation-title">${title}</div>
        <div class="confirmation-message">${message}</div>
        <div class="confirmation-buttons">
          <button class="confirm-btn">Confirm</button>
          <button class="cancel-btn">Cancel</button>
        </div>
      </div>
    `

    document.body.appendChild(dialog)

    dialog.querySelector(".confirm-btn").addEventListener("click", () => {
      playClickSound()
      onConfirm()
      document.body.removeChild(dialog)
    })

    dialog.querySelector(".cancel-btn").addEventListener("click", () => {
      playClickSound()
      document.body.removeChild(dialog)
    })
  }

  const textInputs = document.querySelectorAll('input[type="text"], input[type="number"]')
  textInputs.forEach((input) => {
    input.addEventListener("input", () => {
      playTypeSound()
    })
  })
})

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    document.getElementById("app").style.display = "none"
    document.getElementById("stash-list-container").style.display = "none"
    document.getElementById("stash-details-container").style.display = "none"
    document.getElementById("controls-helper").style.display = "none"
    document.getElementById("dimensions-display").style.display = "none"

    if (typeof isEditMode === "function" && isEditMode()) {
      if (typeof resetEditMode === "function") {
        resetEditMode()
      }
    }

    fetch(`https://${GetParentResourceName()}/closeUI`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    }).catch(() => {
      if ("invokeNative" in window) {
        window.invokeNative("closeApplication")
      }
    })

    playExitUISound()
  }
})

function updateZoneDisplay() {}
function RegisterNUICallback() {}
function TriggerServerEvent() {}
function SetNuiFocus() {}

