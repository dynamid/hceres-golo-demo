module Shell

import Distributed

import java.awt.event
import javax.swing
import javax.swing.WindowConstants

function main = |args| {

  let messages = distributed_list("messages")

  let frame = JFrame("Console")
  frame: setDefaultCloseOperation(EXIT_ON_CLOSE())
  let textField = JTextField(33)
  textField: setFont(textField: getFont(): deriveFont(42.0_F))

  textField: addActionListener(|event| {
    let line = textField: getText()
    if not line: isEmpty() {
      messages: add(line)
      textField: setText("")
    }
  })

  frame: getContentPane(): add(textField)
  frame: pack()
  frame: setVisible(true)
}
