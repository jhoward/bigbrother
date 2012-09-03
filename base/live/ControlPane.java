import java.awt.*;
import javax.swing.*;
import java.awt.event.*;

public class ControlPane extends JSplitPane {

   private ActionListener liveListener;

   public ControlPane() {
      super();

      JScrollPane mssgPanel = new JScrollPane();
      JTextArea mssgArea = new JTextArea();
      mssgArea.setEditable( false );

      mssgPanel.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
      mssgPanel.setAutoscrolls(true);

      JPanel panel = new JPanel(new BorderLayout());

      mssgPanel.getViewport().add(mssgArea, null);
      mssgArea.setFont(new java.awt.Font("Monospaced", Font.PLAIN, 12));

      panel.add(mssgPanel, BorderLayout.CENTER);
      JPanel buttonPanel = new JPanel(new FlowLayout());
      JButton connectButton = new JButton("Connect to Testbed");
   
      connectButton.addActionListener(new java.awt.event.ActionListener() {
         public void actionPerformed(ActionEvent e) {
            ActionEvent ev = new ActionEvent(this, 0, "connectButton");
            liveListener.actionPerformed(ev);
         }
      });

      buttonPanel.add(connectButton);

      this.setOrientation(JSplitPane.VERTICAL_SPLIT);
      this.setLeftComponent(buttonPanel);
      this.setRightComponent(panel);
   }

   public void setLiveListener(ActionListener l) {
      liveListener = l;
   }

} // end public class ControlPane
