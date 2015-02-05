module Rpi

import com.pi4j.io.gpio
import com.pi4j.io.gpio.event

function main = |args| {
  
  let gpio = GpioFactory.getInstance()
  let leds = [
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_00()),
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_01()),
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_02()),
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_03()),
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_04()),
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_05()),
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_06()),
    gpio: provisionDigitalOutputPin(RaspiPin.GPIO_07())
  ]
  
  let topic = Distributed.topic("blink")
  topic: addMessageListener(|message| {
    leds: each(|led| {
      led: high()
      sleep(50_L)
    })
    sleep(500_L)
    leds: each(|led| {
      led: low()
      sleep(50_L)
    })
  })
}
